import "dart:async";
import "dart:ui";

import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/notifications/goal_reminder_notifications.dart";
import "package:timing/core/services/notifications/goal_reminder_service.dart";

class _FakeRepository implements DailyTasksRepository {
  List<DailyTaskEntity> tasks = [];
  final StreamController<List<DailyTaskEntity>> changes =
      StreamController<List<DailyTaskEntity>>.broadcast(sync: true);

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getLocalTasks() async =>
      Right(List.of(tasks));

  @override
  Stream<List<DailyTaskEntity>> get onLocalTasksChanged => changes.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Stands in for the system: holds what is waiting and what is on screen, and
/// logs every call.
class _FakeNotifications implements GoalReminderNotifications {
  _FakeNotifications({required this.canRepeatFromAnyDay});

  @override
  final bool canRepeatFromAnyDay;

  bool allowed = true;
  final Map<int, GoalReminder> scheduled = {};
  final Set<int> shown = {};
  final List<String> calls = [];

  /// The system showing a reminder whose time has come.
  void fire(int id) {
    final GoalReminder reminder = scheduled[id]!;
    if (!reminder.repeatsDaily) {
      scheduled.remove(id);
    }
    shown.add(id);
  }

  @override
  Future<bool> canNotify() async => allowed;

  @override
  Future<Set<int>> scheduledIds() async => scheduled.keys.toSet();

  @override
  Future<Set<int>> shownIds() async => Set.of(shown);

  @override
  Future<void> schedule(
    GoalReminder reminder, {
    required String channelName,
  }) async {
    calls.add("schedule ${reminder.title}");
    scheduled[reminder.id] = reminder;
  }

  @override
  Future<void> cancel(int id) async {
    calls.add("cancel");
    scheduled.remove(id);
    shown.remove(id);
  }
}

const int _noon = 12 * 60;

DailyTaskEntity _goal(
  String id, {
  int? reminder = _noon,
  List<String> done = const [],
}) => DailyTaskEntity(
  id: id,
  name: "Meta $id",
  colorValue: 1,
  targetDays: 0,
  completedDates: done,
  reminderMinutes: reminder,
);

void main() {
  late _FakeRepository repository;
  late _FakeNotifications notifications;
  late GoalReminderService service;
  late DateTime now;

  final String today = DailyTaskEntity.dateKey(DateTime(2026, 10, 7));
  int idOf(String key) => GoalReminderService.notificationIdFor(key);

  void build({required bool canRepeat}) {
    now = DateTime(2026, 10, 7, 9);
    repository = _FakeRepository();
    notifications = _FakeNotifications(canRepeatFromAnyDay: canRepeat);
    service = GoalReminderService(
      dailyTasksRepository: repository,
      notifications: notifications,
      logger: AppLoggerService(),
      now: () => now,
    )..start();
  }

  Future<void> configure({bool enabled = true}) =>
      service.configure(enabled: enabled, locale: const Locale("pt"));

  /// A save somewhere in the app, then the reminders catching up with it.
  Future<void> save(List<DailyTaskEntity> tasks) async {
    repository.tasks = tasks;
    repository.changes.add(tasks);
    await pumpEventQueue();
  }

  List<DateTime> fireTimes() =>
      notifications.scheduled.values.map((reminder) => reminder.fireAt).toList()
        ..sort();

  tearDown(() => service.dispose());

  group("with a notification that repeats from any day (Android)", () {
    setUp(() => build(canRepeat: true));

    test("an unchecked goal is reminded today at its time, daily", () async {
      repository.tasks = [_goal("a")];

      await configure();

      final GoalReminder reminder = notifications.scheduled[idOf("a")]!;
      expect(reminder.fireAt, DateTime(2026, 10, 7, 12));
      expect(reminder.repeatsDaily, true);
      expect(reminder.title, "Meta a");
      expect(reminder.body, "Você ainda não marcou essa meta hoje.");
    });

    test("checking the goal before its time skips today", () async {
      repository.tasks = [_goal("a")];
      await configure();

      await save([
        _goal("a", done: [today]),
      ]);

      expect(fireTimes(), [DateTime(2026, 10, 8, 12)]);
    });

    test("unchecking it before its time brings the reminder back", () async {
      repository.tasks = [
        _goal("a", done: [today]),
      ];
      await configure();

      await save([_goal("a")]);

      expect(fireTimes(), [DateTime(2026, 10, 7, 12)]);
    });

    test("a goal left unchecked past its time waits for tomorrow", () async {
      now = DateTime(2026, 10, 7, 13);
      repository.tasks = [_goal("a")];

      await configure();

      expect(fireTimes(), [DateTime(2026, 10, 8, 12)]);
    });

    test("checking a goal takes its shown reminder off the screen and keeps "
        "tomorrow's", () async {
      repository.tasks = [_goal("a")];
      await configure();
      notifications.fire(idOf("a"));
      now = DateTime(2026, 10, 7, 13);

      await save([
        _goal("a", done: [today]),
      ]);

      expect(notifications.shown, isEmpty);
      expect(fireTimes(), [DateTime(2026, 10, 8, 12)]);
    });

    test("a shown reminder that still holds is left on screen", () async {
      repository.tasks = [_goal("a"), _goal("b")];
      await configure();
      notifications
        ..fire(idOf("a"))
        ..fire(idOf("b"));
      now = DateTime(2026, 10, 7, 13);

      await save([
        _goal("a"),
        _goal("b", done: [today]),
      ]);

      expect(notifications.shown, {idOf("a")});
    });

    test("yesterday's reminder is cleared when the app is opened", () async {
      repository.tasks = [_goal("a")];
      await configure();
      notifications.fire(idOf("a"));
      now = DateTime(2026, 10, 8, 8);

      await service.refresh();

      expect(notifications.shown, isEmpty);
      expect(fireTimes(), [DateTime(2026, 10, 8, 12)]);
    });

    test("only goals with a reminder time are scheduled", () async {
      repository.tasks = [_goal("a"), _goal("b", reminder: null)];

      await configure();

      expect(notifications.scheduled.keys, [idOf("a")]);
    });

    test("removing the reminder or the goal cancels it", () async {
      repository.tasks = [_goal("a"), _goal("b")];
      await configure();

      await save([_goal("a", reminder: null)]);

      expect(notifications.scheduled, isEmpty);
    });

    test("a save that changes nothing about reminders does no work", () async {
      repository.tasks = [_goal("a")];
      await configure();
      notifications.calls.clear();

      await save([_goal("a")]);
      await service.refresh();

      expect(notifications.calls, isEmpty);
    });

    test("nothing is scheduled before the preference is known", () async {
      await save([_goal("a")]);

      expect(notifications.scheduled, isEmpty);
    });

    test("turning notifications off cancels every reminder", () async {
      repository.tasks = [_goal("a"), _goal("b")];
      await configure();
      notifications.fire(idOf("a"));

      await configure(enabled: false);

      expect(notifications.scheduled, isEmpty);
      expect(notifications.shown, isEmpty);
    });

    test("without the system permission nothing is scheduled", () async {
      notifications.allowed = false;
      repository.tasks = [_goal("a")];

      await configure();

      expect(notifications.scheduled, isEmpty);
    });

    test("a reminder left by an earlier run for a gone goal is cancelled on "
        "the first sync", () async {
      final int staleId = idOf("deleted");
      notifications.scheduled[staleId] = GoalReminder(
        id: staleId,
        title: "Meta deleted",
        body: "",
        fireAt: DateTime(2026, 10, 7, 12),
        repeatsDaily: true,
      );

      await configure();

      expect(notifications.scheduled, isEmpty);
    });

    test(
      "signing out, which empties the goals, cancels the reminders",
      () async {
        repository.tasks = [_goal("a")];
        await configure();

        repository.tasks = [];
        await service.refresh();

        expect(notifications.scheduled, isEmpty);
      },
    );

    test("reminder text follows the app language", () async {
      repository.tasks = [_goal("a")];
      await configure();

      await service.configure(enabled: true, locale: const Locale("en"));

      expect(
        notifications.scheduled[idOf("a")]!.body,
        "You haven't checked off this goal today.",
      );
    });
  });

  group("with one notification per day (iOS)", () {
    setUp(() => build(canRepeat: false));

    test("an unchecked goal gets one reminder a day, from today", () async {
      repository.tasks = [_goal("a")];

      await configure();

      final List<DateTime> times = fireTimes();
      expect(times, hasLength(14));
      expect(times.first, DateTime(2026, 10, 7, 12));
      expect(times.last, DateTime(2026, 10, 20, 12));
      expect(
        notifications.scheduled.values.every((r) => !r.repeatsDaily),
        true,
      );
    });

    test("checking the goal before its time drops only today's", () async {
      repository.tasks = [_goal("a")];
      await configure();

      await save([
        _goal("a", done: [today]),
      ]);

      final List<DateTime> times = fireTimes();
      expect(times.first, DateTime(2026, 10, 8, 12));
      expect(times, hasLength(14));
    });

    test("unchecking it before its time brings today's back", () async {
      repository.tasks = [
        _goal("a", done: [today]),
      ];
      await configure();

      await save([_goal("a")]);

      expect(fireTimes().first, DateTime(2026, 10, 7, 12));
    });

    test("checking a goal takes its shown reminder off the screen", () async {
      repository.tasks = [_goal("a")];
      await configure();
      notifications.fire(idOf("a@$today"));
      now = DateTime(2026, 10, 7, 13);

      await save([
        _goal("a", done: [today]),
      ]);

      expect(notifications.shown, isEmpty);
      expect(fireTimes().first, DateTime(2026, 10, 8, 12));
    });

    test("a shown reminder that still holds is left on screen", () async {
      repository.tasks = [_goal("a")];
      await configure();
      notifications.fire(idOf("a@$today"));
      now = DateTime(2026, 10, 7, 13);

      await service.refresh();

      expect(notifications.shown, {idOf("a@$today")});
    });

    test("opening the app on a later day clears old reminders and tops the "
        "days up", () async {
      repository.tasks = [_goal("a")];
      await configure();
      notifications
        ..fire(idOf("a@2026-10-07"))
        ..fire(idOf("a@2026-10-08"));
      now = DateTime(2026, 10, 9, 8);

      await service.refresh();

      expect(notifications.shown, isEmpty);
      final List<DateTime> times = fireTimes();
      expect(times.first, DateTime(2026, 10, 9, 12));
      expect(times.last, DateTime(2026, 10, 22, 12));
    });

    test("changing the time moves every pending day", () async {
      repository.tasks = [_goal("a")];
      await configure();

      await save([_goal("a", reminder: 18 * 60 + 30)]);

      final List<DateTime> times = fireTimes();
      expect(times, hasLength(14));
      expect(times.first, DateTime(2026, 10, 7, 18, 30));
    });

    test("removing the reminder cancels every pending day", () async {
      repository.tasks = [_goal("a")];
      await configure();

      await save([_goal("a", reminder: null)]);

      expect(notifications.scheduled, isEmpty);
    });

    test("many goals share the system's limit, nearest days first", () async {
      repository.tasks = [for (int i = 0; i < 10; i++) _goal("g$i")];

      await configure();

      final List<DateTime> times = fireTimes();
      expect(times, hasLength(60));
      expect(times.first, DateTime(2026, 10, 7, 12));
      expect(times.last, DateTime(2026, 10, 12, 12));
    });

    test("a day that is already waiting is not scheduled again", () async {
      repository.tasks = [_goal("a")];
      await configure();
      notifications.calls.clear();
      now = DateTime(2026, 10, 7, 10);

      await save([_goal("a")]);

      expect(notifications.calls, isEmpty);
    });
  });

  test("notification ids are stable and clear of the timer's", () {
    expect(idOf("1759795200000000-abc"), idOf("1759795200000000-abc"));
    expect(idOf("a"), isNot(idOf("b")));
    expect(idOf("a@2026-10-07"), isNot(idOf("a@2026-10-08")));
    expect(idOf("a"), greaterThan(1 << 29));
    expect(idOf("a"), lessThanOrEqualTo(0x7fffffff));
  });
}
