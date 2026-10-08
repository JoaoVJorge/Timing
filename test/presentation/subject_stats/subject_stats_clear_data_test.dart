import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/subject_stats/subject_stats_controller.dart";
import "package:timing/presentation/subject_stats/subject_stats_page.dart";
import "package:timing/theme/theme.dart";

import "../../support/subject_stats_test_support.dart";
import "../../support/supabase_test_harness.dart";

SubjectEntity _subject({String? groupId}) => SubjectEntity(
  id: "subject-1",
  name: "Cálculo",
  category: TimeCategoryType.studying,
  colorValue: 0xFF2196F3,
  totalSeconds: 3600,
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

/// Answers "yes, delete" and remembers what it was asked.
class _Asked {
  String? itemName;
  bool? isGoal;
  bool? isFromGroup;
  int times = 0;

  Future<bool> yes({
    required String itemName,
    required bool isGoal,
    required bool isFromGroup,
  }) async {
    times++;
    this.itemName = itemName;
    this.isGoal = isGoal;
    this.isFromGroup = isFromGroup;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  group("SubjectStatsController.onClearData", () {
    test("does nothing when the user says no", () async {
      final FakeClearSubjectDataUseCase useCase = FakeClearSubjectDataUseCase();
      final RecordingNavigator navigator = RecordingNavigator();
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        clearUseCase: useCase..subject = _subject(),
        navigator: navigator,
      );

      await controller.onClearData();

      expect(useCase.calls, isEmpty);
      expect(controller.subject.totalSeconds, 3600);
      expect(navigator.successMessages, isEmpty);
    });

    test("asks about this activity, saying whether it is a group's", () async {
      final _Asked asked = _Asked();
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(groupId: "g1"),
        history: _history(),
        clearUseCase: FakeClearSubjectDataUseCase()..subject = _subject(),
        confirmClearData: asked.yes,
      );

      await controller.onClearData();

      expect(asked.itemName, "Cálculo");
      expect(asked.isGoal, isFalse);
      expect(asked.isFromGroup, isTrue);
    });

    test("clears it, shows it at zero and says so", () async {
      final FakeClearSubjectDataUseCase useCase = FakeClearSubjectDataUseCase();
      final RecordingNavigator navigator = RecordingNavigator();
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        clearUseCase: useCase..subject = _subject(),
        navigator: navigator,
        confirmClearData: _Asked().yes,
      );

      await controller.onClearData();

      expect(useCase.calls, ["subject-1"]);
      expect(controller.subject.totalSeconds, 0);
      expect(controller.progress, 0);
      expect(navigator.successMessages, hasLength(1));
      expect(navigator.errorMessages, isEmpty);
      expect(controller.isClearingData.value, isFalse);
    });

    test("a group activity tells the group its ranking changed", () async {
      final ActivityChangeBus bus = ActivityChangeBus();
      final List<String?> groups = <String?>[];
      final StreamSubscription<GroupActivityChange> subscription = bus.stream
          .listen((change) => groups.add(change.groupId));
      addTearDown(subscription.cancel);
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(groupId: "g1"),
        history: _history(),
        clearUseCase: FakeClearSubjectDataUseCase()
          ..subject = _subject(groupId: "g1"),
        activityChangeBus: bus,
        confirmClearData: _Asked().yes,
      );

      await controller.onClearData();
      await Future<void>.delayed(Duration.zero);

      expect(groups, ["g1"]);
    });

    test("a personal activity does not bother the groups", () async {
      final ActivityChangeBus bus = ActivityChangeBus();
      int notifications = 0;
      final StreamSubscription<GroupActivityChange> subscription = bus.stream
          .listen((_) => notifications++);
      addTearDown(subscription.cancel);
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        clearUseCase: FakeClearSubjectDataUseCase()..subject = _subject(),
        activityChangeBus: bus,
        confirmClearData: _Asked().yes,
      );

      await controller.onClearData();
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 0);
    });

    test("a failure leaves the numbers as they were and reports it", () async {
      final RecordingNavigator navigator = RecordingNavigator();
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        clearUseCase: FakeClearSubjectDataUseCase(
          result: Left(
            GenericAppError(error: "boom", stackTrace: StackTrace.current),
          ),
        ),
        navigator: navigator,
        confirmClearData: _Asked().yes,
      );

      await controller.onClearData();

      expect(controller.subject.totalSeconds, 3600);
      expect(navigator.errorMessages, hasLength(1));
      expect(navigator.successMessages, isEmpty);
      expect(controller.isClearingData.value, isFalse);
    });

    test("a second tap while it is working is ignored", () async {
      final Completer<Either<AppError, SubjectEntity>> gate =
          Completer<Either<AppError, SubjectEntity>>();
      final _GatedUseCase useCase = _GatedUseCase(gate.future);
      final _Asked asked = _Asked();
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        clearUseCase: useCase,
        confirmClearData: asked.yes,
      );

      final Future<void> first = controller.onClearData();
      await Future<void>.delayed(Duration.zero);
      expect(controller.isClearingData.value, isTrue);
      await controller.onClearData();

      gate.complete(Right(_subject().copyWith(totalSeconds: 0)));
      await first;

      expect(asked.times, 1);
      expect(useCase.askedTimes, 1);
    });
  });

  group("the delete-data button on the stats page", () {
    Future<(SubjectStatsController, RecordingNavigator)> pumpPage(
      WidgetTester tester, {
      required Future<bool> Function({
        required String itemName,
        required bool isGoal,
        required bool isFromGroup,
      })
      confirm,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final RecordingNavigator navigator = RecordingNavigator();
      final SubjectStatsController controller = buildStatsController(
        subject: _subject(),
        history: _history(),
        clearUseCase: FakeClearSubjectDataUseCase()..subject = _subject(),
        navigator: navigator,
        confirmClearData: confirm,
      );
      Get.put<AppNavigator>(AppNavigator());
      Get.put<SubjectStatsController>(controller);

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale("pt"),
          theme: AppThemes.build(
            seed: Colors.blue,
            brightness: Brightness.light,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SubjectStatsPage(),
        ),
      );
      await tester.pump();
      return (controller, navigator);
    }

    Finder button() => find.byKey(const ValueKey("clear-subject-data"));

    testWidgets("sits at the end of the statistics", (tester) async {
      await pumpPage(tester, confirm: _Asked().yes);

      expect(button(), findsOneWidget);
      expect(
        find.descendant(of: button(), matching: find.text("Apagar dados")),
        findsOneWidget,
      );
      // Below the comparisons, which are the last statistics.
      expect(
        tester.getTopLeft(button()).dy,
        greaterThan(tester.getTopLeft(find.text("Comparativos")).dy),
      );
    });

    testWidgets("asks first: saying no keeps the numbers", (tester) async {
      await pumpPage(
        tester,
        confirm:
            ({
              required String itemName,
              required bool isGoal,
              required bool isFromGroup,
            }) async => false,
      );
      expect(find.text("50%"), findsOneWidget);

      await tester.ensureVisible(button());
      await tester.tap(button());
      await tester.pumpAndSettle();

      expect(find.text("50%"), findsOneWidget);
    });

    testWidgets("saying yes redraws the page from zero", (tester) async {
      final (SubjectStatsController controller, RecordingNavigator navigator) =
          await pumpPage(tester, confirm: _Asked().yes);
      expect(find.text("50%"), findsOneWidget);

      await tester.ensureVisible(button());
      await tester.tap(button());
      await tester.pumpAndSettle();

      expect(controller.subject.totalSeconds, 0);
      expect(find.text("0%"), findsOneWidget);
      expect(find.text("50%"), findsNothing);
      expect(navigator.successMessages, hasLength(1));
    });
  });
}

class _GatedUseCase extends FakeClearSubjectDataUseCase {
  _GatedUseCase(this._gate);

  final Future<Either<AppError, SubjectEntity>> _gate;
  int askedTimes = 0;

  @override
  Future<Either<AppError, SubjectEntity>> call({required String subjectId}) {
    askedTimes++;
    return _gate;
  }
}
