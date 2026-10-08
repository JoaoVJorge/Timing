import "dart:async";
import "dart:ui" show Locale;

import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";
import "package:flutter/foundation.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/notifications/goal_reminder_notifications.dart";
import "package:timing/l10n/app_localizations.dart";

/// Keeps a daily notification for every goal that has a reminder time.
///
/// A reminder is due every day at the goal's time, starting from the next day
/// it still applies. Checking a goal therefore pushes its reminder to tomorrow,
/// and unchecking it before the time brings it back to today.
///
/// Where the system can start a repeating notification on a chosen day, each
/// goal has one that repeats forever. Elsewhere each of the coming days gets a
/// notification of its own, topped up whenever the app is opened.
class GoalReminderService {
  GoalReminderService({
    required this._dailyTasksRepository,
    required this._notifications,
    required this._logger,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final DailyTasksRepository _dailyTasksRepository;
  final GoalReminderNotifications _notifications;
  final AppLoggerService _logger;
  final DateTime Function() _now;

  StreamSubscription<List<DailyTaskEntity>>? _tasksSubscription;
  Future<void> _syncTail = Future<void>.value();

  /// Null until the saved preference is known, so nothing is scheduled for a
  /// user who turned notifications off before the app finished loading.
  bool? _enabled;
  Locale? _locale;

  /// What this run last handed to the system, to skip work when a save changes
  /// nothing a reminder depends on. Null while that is unknown, which makes
  /// the next sync compare against what the system actually holds.
  _ReminderPlan? _applied;

  /// How many days ahead get a notification each when one cannot repeat.
  static const int _singleDayHorizon = 14;

  /// iOS keeps at most 64 pending notifications per app; the rest of the room
  /// is left to anything else the app may schedule.
  static const int _maxSingleDayReminders = 60;

  /// Follows every change to the goals saved on this device.
  void start() {
    _tasksSubscription ??= _dailyTasksRepository.onLocalTasksChanged.listen(
      _enqueueSync,
    );
  }

  Future<void> dispose() async {
    await _tasksSubscription?.cancel();
    _tasksSubscription = null;
  }

  /// Applies the notifications preference and the language of the reminder
  /// text, then brings the reminders in line with them.
  Future<void> configure({required bool enabled, required Locale locale}) {
    _enabled = enabled;
    _locale = locale;
    return refresh();
  }

  /// Re-reads the goals saved on this device. For the moments reminders can
  /// be out of date without a goal having been saved: the app starting or
  /// coming back to the foreground, and the account changing.
  Future<void> refresh() async {
    final Either<AppError, List<DailyTaskEntity>> result =
        await _dailyTasksRepository.getLocalTasks();
    await result.fold((_) async {}, _enqueueSync);
  }

  /// A stable notification id for a goal, clear of the small ids the timer
  /// and achievement notifications use. 30 bits keep two goals of one user
  /// from sharing an id in practice.
  @visibleForTesting
  static int notificationIdFor(String taskId) {
    int hash = 0x811c9dc5;
    for (final int unit in taskId.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return 0x40000000 | (hash & 0x3fffffff);
  }

  Future<void> _enqueueSync(List<DailyTaskEntity> tasks) {
    final Future<void> scheduled = _syncTail.then((_) => _sync(tasks));
    _syncTail = scheduled;
    return scheduled;
  }

  Future<void> _sync(List<DailyTaskEntity> tasks) async {
    final bool? enabled = _enabled;
    final Locale? locale = _locale;
    if (enabled == null || locale == null) {
      return;
    }

    try {
      final AppLocalizations l10n = lookupAppLocalizations(locale);
      final _ReminderPlan plan = enabled && await _notifications.canNotify()
          ? _planFor(tasks, l10n)
          : _ReminderPlan.none;
      final _ReminderPlan? applied = _applied;
      if (plan == applied) {
        return;
      }

      final Set<int> scheduled = await _notifications.scheduledIds();
      // A reminder on screen stops being true once its goal is checked or its
      // day is over, even when the goal's next reminder is still wanted.
      final Set<int> outdatedShown = (await _notifications.shownIds())
          .difference(plan.stillTrueOnScreen);
      final Set<int> toCancel = {
        ...scheduled.where((id) => !plan.reminders.containsKey(id)),
        ...outdatedShown,
      };
      for (final int id in toCancel) {
        await _notifications.cancel(id);
      }
      for (final GoalReminder reminder in plan.reminders.values) {
        if (applied?.reminders[reminder.id] == reminder &&
            scheduled.contains(reminder.id) &&
            !toCancel.contains(reminder.id)) {
          continue;
        }
        await _notifications.schedule(
          reminder,
          channelName: l10n.goalReminderChannelName,
        );
      }
      _applied = plan;
    } catch (error, stackTrace) {
      // Goals must keep working even when reminders cannot be scheduled.
      _applied = null;
      _logger.logError(
        "GoalReminderService failed to sync reminders",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  _ReminderPlan _planFor(List<DailyTaskEntity> tasks, AppLocalizations l10n) {
    final DateTime now = _now();
    final String today = DailyTaskEntity.dateKey(now);
    final bool repeats = _notifications.canRepeatFromAnyDay;
    final List<GoalReminder> reminders = <GoalReminder>[];
    final Set<int> stillTrueOnScreen = <int>{};

    for (final DailyTaskEntity task in tasks) {
      final DateTime? next = task.nextReminderAt(now);
      if (next == null) {
        continue;
      }
      // Today's reminder has been shown and still holds: the goal is unchecked
      // and its time has passed.
      if (next.day != now.day && !task.completedDates.contains(today)) {
        stillTrueOnScreen.add(_idFor(task, now, repeats: repeats));
      }
      for (int day = 0; day < (repeats ? 1 : _singleDayHorizon); day++) {
        final DateTime fireAt = DateTime(
          next.year,
          next.month,
          next.day + day,
          next.hour,
          next.minute,
        );
        reminders.add(
          GoalReminder(
            id: _idFor(task, fireAt, repeats: repeats),
            title: task.name,
            body: l10n.goalReminderNotificationBody,
            fireAt: fireAt,
            repeatsDaily: repeats,
          ),
        );
      }
    }

    if (!repeats && reminders.length > _maxSingleDayReminders) {
      // With many goals the nearest days are the ones worth keeping.
      reminders.sort((a, b) => a.fireAt.compareTo(b.fireAt));
      reminders.length = _maxSingleDayReminders;
    }
    return _ReminderPlan(
      reminders: {
        for (final GoalReminder reminder in reminders) reminder.id: reminder,
      },
      stillTrueOnScreen: stillTrueOnScreen,
    );
  }

  /// A repeating reminder keeps one id for the goal; single-day ones need an
  /// id per day.
  int _idFor(DailyTaskEntity task, DateTime day, {required bool repeats}) =>
      notificationIdFor(
        repeats ? task.id : "${task.id}@${DailyTaskEntity.dateKey(day)}",
      );
}

/// The reminders that should be waiting, and the ones that may rightly be on
/// screen at the moment.
class _ReminderPlan extends Equatable {
  const _ReminderPlan({
    required this.reminders,
    required this.stillTrueOnScreen,
  });

  static const _ReminderPlan none = _ReminderPlan(
    reminders: <int, GoalReminder>{},
    stillTrueOnScreen: <int>{},
  );

  final Map<int, GoalReminder> reminders;
  final Set<int> stillTrueOnScreen;

  @override
  List<Object?> get props => [reminders, stillTrueOnScreen];
}
