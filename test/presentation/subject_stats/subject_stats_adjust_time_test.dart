import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_subject_time_use_case.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/subject_stats/subject_stats_controller.dart";
import "package:timing/presentation/subject_stats/subject_stats_page.dart";
import "package:timing/presentation/subject_stats/widgets/time_adjustment_dialog.dart";
import "package:timing/theme/theme.dart";

import "../../support/subject_stats_test_support.dart";
import "../../support/supabase_test_harness.dart";

SubjectEntity _subject({int seconds = 3600, String? groupId}) => SubjectEntity(
  id: "subject-1",
  name: "Cálculo",
  category: TimeCategoryType.studying,
  colorValue: 0xFF2196F3,
  totalSeconds: seconds,
  goalSeconds: 7200,
  currentPages: 0,
  goalPages: 0,
  notes: "",
  iconName: "",
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
  activityType: SubjectActivityType.permanent,
  groupId: groupId,
  groupActivityId: groupId == null ? null : "ga1",
);

SubjectDailyHistoryService _history() =>
    SubjectDailyHistoryService(localStorageService: MemoryStorage());

/// Answers the "how much?" question and remembers how it was asked.
class _Picker {
  _Picker(this.answer);

  final int? answer;
  bool? isRemoving;
  int? maxSeconds;
  int times = 0;

  Future<int?> pick({required bool isRemoving, required int maxSeconds}) async {
    times++;
    this.isRemoving = isRemoving;
    this.maxSeconds = maxSeconds;
    return answer;
  }
}

Widget _app(
  Widget home, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) => GetMaterialApp(
  locale: const Locale("pt"),
  theme: AppThemes.build(seed: Colors.blue, brightness: brightness),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  group("adjusting an activity's time", () {
    test(
      "adding asks how much, up to a day, and shows the new total",
      () async {
        final FakeSubjectTimeUseCase add = FakeSubjectTimeUseCase(
          subject: _subject(),
          sign: 1,
        );
        final FakeAchievementUnlockService achievements =
            FakeAchievementUnlockService();
        final _Picker picker = _Picker(1800);
        final SubjectStatsController controller = buildStatsController(
          subject: _subject(),
          history: _history(),
          addTimeUseCase: add,
          achievements: achievements,
          pickTimeAmount: picker.pick,
        );

        await controller.onAddTime();
        await pumpEventQueue();

        expect(picker.isRemoving, isFalse);
        expect(picker.maxSeconds, AddSubjectTimeUseCase.maxSeconds);
        expect(add.calls, [1800]);
        expect(controller.subject.totalSeconds, 5400);
        // More time can complete an achievement, as a timer session can.
        expect(achievements.checks, 1);
        expect(controller.isAdjustingTime.value, isFalse);
      },
    );

    test("removing offers at most what the activity has", () async {
      final FakeSubjectTimeUseCase remove = FakeSubjectTimeUseCase(
        subject: _subject(),
        sign: -1,
      );
      final FakeAchievementUnlockService achievements =
          FakeAchievementUnlockService();
      final _Picker picker = _Picker(600);
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        removeTimeUseCase: remove,
        achievements: achievements,
        pickTimeAmount: picker.pick,
      );

      await controller.onRemoveTime();

      expect(picker.isRemoving, isTrue);
      expect(picker.maxSeconds, 3600);
      expect(remove.calls, [600]);
      expect(controller.subject.totalSeconds, 3000);
      expect(achievements.checks, 0);
    });

    test("giving up on the amount changes nothing", () async {
      final FakeSubjectTimeUseCase add = FakeSubjectTimeUseCase(
        subject: _subject(),
        sign: 1,
      );
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        addTimeUseCase: add,
        pickTimeAmount: _Picker(null).pick,
      );

      await controller.onAddTime();

      expect(add.calls, isEmpty);
      expect(controller.subject.totalSeconds, 3600);
    });

    test("an activity with no time has nothing to remove", () async {
      final _Picker picker = _Picker(600);
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(seconds: 0),
        history: _history(),
        pickTimeAmount: picker.pick,
      );

      await controller.onRemoveTime();

      expect(controller.canRemoveTime, isFalse);
      expect(picker.times, 0);
    });

    test("a failure is reported and the numbers stay", () async {
      final FakeSubjectTimeUseCase remove =
          FakeSubjectTimeUseCase(subject: _subject(), sign: -1)
            ..failure = UnexpectedError(
              cause: "boom",
              stackTrace: StackTrace.current,
            );
      final RecordingNavigator navigator = RecordingNavigator();
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        removeTimeUseCase: remove,
        navigator: navigator,
        pickTimeAmount: _Picker(600).pick,
      );

      await controller.onRemoveTime();

      expect(controller.subject.totalSeconds, 3600);
      expect(navigator.errorMessages, hasLength(1));
      expect(navigator.successMessages, isEmpty);
    });

    test("a group activity tells its group", () async {
      final ActivityChangeBus bus = ActivityChangeBus();
      final List<String?> notified = <String?>[];
      final StreamSubscription<GroupActivityChange> subscription = bus.stream
          .listen((change) => notified.add(change.groupId));
      addTearDown(subscription.cancel);
      final SubjectEntity subject = _subject(groupId: "g1");
      final SubjectStatsController controller = buildStatsController(
        subject: subject,
        history: _history(),
        removeTimeUseCase: FakeSubjectTimeUseCase(subject: subject, sign: -1),
        activityChangeBus: bus,
        pickTimeAmount: _Picker(600).pick,
      );

      await controller.onRemoveTime();
      await pumpEventQueue();

      expect(notified, ["g1"]);
    });
  });

  group("the adjust-time buttons on the stats page", () {
    Future<(SubjectStatsController, RecordingNavigator)> pumpPage(
      WidgetTester tester, {
      required SubjectEntity subject,
      int? pickedSeconds,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final RecordingNavigator navigator = RecordingNavigator();
      final SubjectStatsController controller = buildStatsController(
        subject: subject,
        history: _history(),
        navigator: navigator,
        pickTimeAmount: _Picker(pickedSeconds).pick,
      );
      Get.put<AppNavigator>(AppNavigator());
      Get.put<SubjectStatsController>(controller);

      await tester.pumpWidget(_app(const SubjectStatsPage()));
      await tester.pump();
      return (controller, navigator);
    }

    Finder addButton() => find.byKey(const ValueKey("add-subject-time"));
    Finder removeButton() => find.byKey(const ValueKey("remove-subject-time"));

    testWidgets("sit at the end of the statistics, above delete data", (
      tester,
    ) async {
      await pumpPage(tester, subject: _subject());

      expect(find.text("Ajustar tempo"), findsOneWidget);
      expect(
        find.descendant(
          of: addButton(),
          matching: find.text("Adicionar tempo"),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: removeButton(),
          matching: find.text("Remover tempo"),
        ),
        findsOneWidget,
      );
      final double buttonsTop = tester.getTopLeft(addButton()).dy;
      expect(
        buttonsTop,
        greaterThan(tester.getTopLeft(find.text("Comparativos")).dy),
      );
      expect(
        buttonsTop,
        lessThan(
          tester
              .getTopLeft(find.byKey(const ValueKey("clear-subject-data")))
              .dy,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets("adding updates the time shown and confirms it", (
      tester,
    ) async {
      final (controller, navigator) = await pumpPage(
        tester,
        subject: _subject(),
        pickedSeconds: 1800,
      );
      expect(find.text("1h"), findsOneWidget);

      await tester.tap(addButton());
      await tester.pumpAndSettle();

      expect(controller.subject.totalSeconds, 5400);
      expect(find.text("1h 30 min"), findsOneWidget);
      expect(navigator.successMessages, ["Tempo adicionado."]);
    });

    testWidgets("removing updates the time shown and confirms it", (
      tester,
    ) async {
      final (controller, navigator) = await pumpPage(
        tester,
        subject: _subject(),
        pickedSeconds: 1200,
      );

      await tester.tap(removeButton());
      await tester.pumpAndSettle();

      expect(controller.subject.totalSeconds, 2400);
      expect(find.text("40 min"), findsOneWidget);
      expect(navigator.successMessages, ["Tempo removido."]);
    });

    testWidgets("remove does nothing while the activity has no time", (
      tester,
    ) async {
      final (controller, navigator) = await pumpPage(
        tester,
        subject: _subject(seconds: 0),
        pickedSeconds: 600,
      );

      await tester.tap(removeButton(), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(controller.subject.totalSeconds, 0);
      expect(navigator.successMessages, isEmpty);
    });
  });

  group("the amount dialog", () {
    Finder value() => find.byKey(const ValueKey("time-adjustment-value"));
    Finder plus() => find.byKey(const ValueKey("time-adjustment-plus"));
    Finder minus() => find.byKey(const ValueKey("time-adjustment-minus"));
    Finder confirm() => find.byKey(const ValueKey("time-adjustment-confirm"));
    String shown(WidgetTester tester) =>
        tester.widget<TextField>(value()).controller!.text;

    testWidgets("opens a bottom sheet at 30 minutes and steps by one", (
      tester,
    ) async {
      Get.put<AppNavigator>(AppNavigator());
      await tester.pumpWidget(
        _app(
          TextButton(
            onPressed: () =>
                showTimeAdjustmentDialog(isRemoving: false, maxSeconds: 86400),
            child: const Text("open"),
          ),
        ),
      );
      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();
      expect(find.text("Adicionar tempo"), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(shown(tester), "30");

      await tester.tap(plus());
      await tester.pump();
      expect(shown(tester), "31");

      await tester.tap(minus());
      await tester.tap(minus());
      await tester.pump();
      expect(shown(tester), "29");
    });

    testWidgets("typed amounts validate before confirmation", (tester) async {
      int? answer;
      Get.put<AppNavigator>(AppNavigator());
      await tester.pumpWidget(
        _app(
          TextButton(
            onPressed: () async => answer = await showTimeAdjustmentDialog(
              isRemoving: false,
              maxSeconds: 86400,
            ),
            child: const Text("open"),
          ),
        ),
      );
      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      for (final invalid in ["", "0", "1441"]) {
        await tester.enterText(value(), invalid);
        await tester.pump();
        expect(tester.widget<FilledButton>(confirm()).onPressed, isNull);
      }
      await tester.enterText(value(), "27");
      await tester.pump();
      expect(find.text("Adicionar 27 min"), findsOneWidget);
      await tester.tap(confirm());
      await tester.pumpAndSettle();
      expect(answer, 27 * 60);
    });

    testWidgets(
      "small dark screen keeps confirmation reachable above keyboard",
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetViewInsets);
        Get.put<AppNavigator>(AppNavigator());
        int? answer;
        await tester.pumpWidget(
          _app(
            TextButton(
              onPressed: () async => answer = await showTimeAdjustmentDialog(
                isRemoving: false,
                maxSeconds: 86400,
              ),
              child: const Text("open"),
            ),
            brightness: Brightness.dark,
            textScale: 1.5,
          ),
        );
        await tester.tap(find.text("open"));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.enterText(value(), "1440");
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();
        await tester.ensureVisible(confirm());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getBottomLeft(confirm()).dy, lessThanOrEqualTo(360));
        await tester.tap(confirm());
        await tester.pumpAndSettle();
        expect(answer, 86400);
      },
    );

    testWidgets("answers with the chosen amount in seconds", (tester) async {
      int? answer;
      Get.put<AppNavigator>(AppNavigator());
      await tester.pumpWidget(
        _app(
          TextButton(
            onPressed: () async => answer = await showTimeAdjustmentDialog(
              isRemoving: false,
              maxSeconds: 86400,
            ),
            child: const Text("open"),
          ),
        ),
      );
      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("1h"));
      await tester.pump();
      await tester.tap(plus());
      await tester.pump();
      expect(shown(tester), "61");
      await tester.tap(confirm());
      await tester.pumpAndSettle();

      expect(answer, 61 * 60);
    });

    testWidgets("cancelling answers nothing", (tester) async {
      int? answer = -1;
      Get.put<AppNavigator>(AppNavigator());
      await tester.pumpWidget(
        _app(
          TextButton(
            onPressed: () async => answer = await showTimeAdjustmentDialog(
              isRemoving: true,
              maxSeconds: 3600,
            ),
            child: const Text("open"),
          ),
        ),
      );
      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip("Fechar"));
      await tester.pumpAndSettle();

      expect(answer, isNull);
    });

    testWidgets("removing never offers more than the activity has", (
      tester,
    ) async {
      int? answer;
      Get.put<AppNavigator>(AppNavigator());
      await tester.pumpWidget(
        _app(
          TextButton(
            onPressed: () async => answer = await showTimeAdjustmentDialog(
              isRemoving: true,
              // 22 minutes and 10 seconds.
              maxSeconds: 22 * 60 + 10,
            ),
            child: const Text("open"),
          ),
        ),
      );
      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      expect(find.text("Remover tempo"), findsOneWidget);
      // Starts at the most there is, and only the presets that fit show.
      expect(shown(tester), "23");
      expect(find.text("15 min"), findsOneWidget);
      expect(find.text("30 min"), findsNothing);

      await tester.tap(plus(), warnIfMissed: false);
      await tester.pump();
      expect(shown(tester), "23");

      await tester.tap(confirm());
      await tester.pumpAndSettle();

      // The last partial minute removes exactly what is left.
      expect(answer, 22 * 60 + 10);
    });

    testWidgets("steps down from the limit and never exceeds it", (
      tester,
    ) async {
      Get.put<AppNavigator>(AppNavigator());
      await tester.pumpWidget(
        _app(
          TextButton(
            onPressed: () =>
                showTimeAdjustmentDialog(isRemoving: true, maxSeconds: 23 * 60),
            child: const Text("open"),
          ),
        ),
      );
      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      await tester.tap(minus());
      await tester.pump();
      expect(shown(tester), "22");

      await tester.tap(plus());
      await tester.pump();
      await tester.tap(plus());
      await tester.pump();
      expect(shown(tester), "23");
    });

    testWidgets("an activity with under a minute can still be emptied", (
      tester,
    ) async {
      int? answer;
      Get.put<AppNavigator>(AppNavigator());
      await tester.pumpWidget(
        _app(
          TextButton(
            onPressed: () async => answer = await showTimeAdjustmentDialog(
              isRemoving: true,
              maxSeconds: 40,
            ),
            child: const Text("open"),
          ),
        ),
      );
      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      expect(shown(tester), "1");
      await tester.tap(confirm());
      await tester.pumpAndSettle();

      expect(answer, 40);
    });
  });
}
