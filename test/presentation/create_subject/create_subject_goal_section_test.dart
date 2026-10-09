import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
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

class _UnusedAdd extends _Unused implements AddSubjectUseCase {}

class _UnusedUpdate extends _Unused implements UpdateSubjectUseCase {}

class _UnusedAchievements extends _Unused implements AchievementUnlockService {}

class _UnusedAnalytics extends _Unused implements AnalyticsService {}

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
      addSubjectUseCase: _UnusedAdd(),
      updateSubjectUseCase: _UnusedUpdate(),
      appNavigator: navigator,
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

/// The message of the info button shown next to a section title.
Finder _infoTooltip(String message) => find.byWidgetPredicate(
  (widget) => widget is Tooltip && widget.message == message,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets("a daily activity has a short goal title with an info button", (
    tester,
  ) async {
    await _pumpForm(tester, TimeCategoryType.studying);

    expect(find.text("Duração de cada seção"), findsOneWidget);
    expect(
      _infoTooltip(
        "Quanto tempo dura cada seção de foco antes de uma pausa ou conclusão.",
      ),
      findsOneWidget,
    );
  });

  testWidgets("a permanent activity gets the same: short title plus info", (
    tester,
  ) async {
    final CreateSubjectController controller = await _pumpForm(
      tester,
      TimeCategoryType.studying,
    );

    controller.setActivityType(SubjectActivityType.permanent);
    await tester.pump();

    expect(find.text("Tempo total"), findsOneWidget);
    // The long question moved into the info button instead of the title.
    expect(find.text("Quanto tempo você quer estudar no total?"), findsNothing);
    expect(
      _infoTooltip("Quanto tempo você quer estudar no total?"),
      findsOneWidget,
    );
    expect(find.text("Duração de cada seção"), findsNothing);
  });

  testWidgets("the info button follows the activity's category", (
    tester,
  ) async {
    final CreateSubjectController controller = await _pumpForm(
      tester,
      TimeCategoryType.exercises,
    );

    controller.setActivityType(SubjectActivityType.permanent);
    await tester.pump();

    expect(find.text("Tempo total"), findsOneWidget);
    expect(
      _infoTooltip("Quanto tempo você quer se exercitar no total?"),
      findsOneWidget,
    );
  });
}
