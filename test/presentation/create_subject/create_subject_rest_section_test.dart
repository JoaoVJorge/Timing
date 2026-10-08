import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_subject_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/analytics/analytics_service.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/create_subject/create_subject_controller.dart";
import "package:timing/presentation/create_subject/create_subject_page.dart";
import "package:timing/theme/theme.dart";

class _Unused {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _RecordingAdd extends _Unused implements AddSubjectUseCase {
  int? savedRestMinutes;
  int? savedFocusSessionCount;

  @override
  Future<Either<AppError, SubjectEntity>> call({
    required String name,
    required TimeCategoryType category,
    required int colorValue,
    required int goalSeconds,
    int goalPages = 0,
    String iconName = "",
    int restMinutes = SubjectEntity.defaultRestMinutes,
    int focusSessionCount = 1,
    int wallpaperIndex = 0,
    SubjectActivityType activityType = SubjectActivityType.daily,
    bool reuseMatchingSubject = false,
    String? groupId,
    String? groupActivityId,
    String? id,
  }) async {
    savedRestMinutes = restMinutes;
    savedFocusSessionCount = focusSessionCount;
    return Left(
      GenericAppError(error: "stops here", stackTrace: StackTrace.empty),
    );
  }
}

class _UnusedUpdate extends _Unused implements UpdateSubjectUseCase {}

/// Swallows snackbars so a save does not leave an animation running past the
/// end of the test.
class _SilentNavigator extends _Unused implements AppNavigator {}

class _UnusedAchievements extends _Unused implements AchievementUnlockService {}

class _UnusedAnalytics extends _Unused implements AnalyticsService {}

late _RecordingAdd _lastAdd;

Future<CreateSubjectController> _pumpForm(
  WidgetTester tester,
  TimeCategoryType category,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 4000);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final AppNavigator navigator = AppNavigator();
  Get.put<AppNavigator>(navigator);
  final CreateSubjectController controller = Get.put<CreateSubjectController>(
    CreateSubjectController(
      addSubjectUseCase: _lastAdd = _RecordingAdd(),
      updateSubjectUseCase: _UnusedUpdate(),
      appNavigator: _SilentNavigator(),
      achievementUnlockService: _UnusedAchievements(),
      analyticsService: _UnusedAnalytics(),
      category: category,
    ),
  );

  await tester.pumpWidget(
    GetMaterialApp(
      locale: const Locale("pt"),
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const CreateSubjectPage(),
    ),
  );
  await tester.pump();
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets("one session hides the break section entirely", (tester) async {
    await _pumpForm(tester, TimeCategoryType.studying);

    expect(find.text("Quantidade de sessões"), findsOneWidget);
    expect(find.text("Duração das pausas"), findsNothing);
  });

  testWidgets("the break section appears as soon as a second session does", (
    tester,
  ) async {
    final CreateSubjectController controller = await _pumpForm(
      tester,
      TimeCategoryType.studying,
    );

    controller.setFocusSessionCount(2);
    await tester.pump();

    expect(find.text("Duração das pausas"), findsOneWidget);
  });

  testWidgets("dropping back to one session hides it again", (tester) async {
    final CreateSubjectController controller = await _pumpForm(
      tester,
      TimeCategoryType.studying,
    );

    controller.setFocusSessionCount(3);
    await tester.pump();
    expect(find.text("Duração das pausas"), findsOneWidget);

    controller.setFocusSessionCount(1);
    await tester.pump();
    expect(find.text("Duração das pausas"), findsNothing);
  });

  testWidgets("saving one session persists no break at all", (tester) async {
    final CreateSubjectController controller = await _pumpForm(
      tester,
      TimeCategoryType.studying,
    );

    controller.nameController.text = "Cálculo";
    controller.goalController.text = "30";
    controller.setRestMinutes(15);
    await controller.onSubmit();

    expect(_lastAdd.savedFocusSessionCount, 1);
    expect(_lastAdd.savedRestMinutes, 0);
  });

  testWidgets("saving two sessions persists the chosen break", (tester) async {
    final CreateSubjectController controller = await _pumpForm(
      tester,
      TimeCategoryType.studying,
    );

    controller.nameController.text = "Cálculo";
    controller.goalController.text = "30";
    controller.setFocusSessionCount(2);
    controller.setRestMinutes(15);
    await controller.onSubmit();

    expect(_lastAdd.savedFocusSessionCount, 2);
    expect(_lastAdd.savedRestMinutes, 15);
  });

  testWidgets("exercises follow the same rule", (tester) async {
    final CreateSubjectController controller = await _pumpForm(
      tester,
      TimeCategoryType.exercises,
    );

    expect(find.text("Duração das pausas"), findsNothing);

    controller.setFocusSessionCount(2);
    await tester.pump();
    expect(find.text("Duração das pausas"), findsOneWidget);
  });
}
