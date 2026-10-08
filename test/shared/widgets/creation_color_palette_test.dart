import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/use_cases/add_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/add_subject_use_case.dart";
import "package:timing/core/domain/use_cases/update_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/analytics/analytics_service.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/create_subject/create_subject_controller.dart";
import "package:timing/presentation/create_subject/create_subject_page.dart";
import "package:timing/presentation/create_task/create_task_controller.dart";
import "package:timing/presentation/create_task/create_task_page.dart";
import "package:timing/presentation/schedule/add_schedule_entry_page.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/theme/subject_colors.dart";
import "package:timing/theme/theme.dart";

import "../../support/pump_in_scroll_view.dart";

class _Unused {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _UnusedAddDailyTask extends _Unused implements AddDailyTaskUseCase {}

class _UnusedUpdateDailyTask extends _Unused
    implements UpdateDailyTaskUseCase {}

class _UnusedAddSubject extends _Unused implements AddSubjectUseCase {}

class _UnusedUpdateSubject extends _Unused implements UpdateSubjectUseCase {}

class _UnusedAchievements extends _Unused implements AchievementUnlockService {}

class _UnusedAnalytics extends _Unused implements AnalyticsService {}

/// Every swatch on screen, in the order the user sees them.
List<Color> _shownColors(WidgetTester tester) => tester
    .widgetList<CreationColorChoice>(find.byType(CreationColorChoice))
    .map((choice) => choice.color)
    .toList();

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  // Tall enough that every section is laid out, not just the first screen.
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 4000);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    GetMaterialApp(
      locale: const Locale("pt"),
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: page,
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  group("CreationColorPalette", () {
    testWidgets("offers all 14 solid colors once, in a fixed order", (
      tester,
    ) async {
      await pumpInScrollView(
        tester,
        CreationColorPalette(
          selectedColor: SubjectColors.values.first,
          onSelect: (_) {},
        ),
      );

      expect(_shownColors(tester), SubjectColors.values);
      expect(_shownColors(tester).toSet(), hasLength(14));
    });

    testWidgets("marks only the selected color and reports the one tapped", (
      tester,
    ) async {
      Color? picked;
      final Color selected = SubjectColors.values[9];

      await pumpInScrollView(
        tester,
        CreationColorPalette(
          selectedColor: selected,
          onSelect: (color) => picked = color,
        ),
      );

      final List<Color> marked = tester
          .widgetList<CreationColorChoice>(find.byType(CreationColorChoice))
          .where((choice) => choice.isSelected)
          .map((choice) => choice.color)
          .toList();
      expect(marked, [selected]);

      await tester.tap(find.byType(CreationColorChoice).at(10));
      expect(picked, SubjectColors.values[10]);
    });

    testWidgets("the section card shows the same palette under its label", (
      tester,
    ) async {
      await pumpInScrollView(
        tester,
        CreationColorSection(
          accent: SubjectColors.values.first,
          label: "Cor",
          onSelect: (_) {},
        ),
      );

      expect(find.text("Cor"), findsOneWidget);
      expect(find.byType(CreationColorPalette), findsOneWidget);
      expect(_shownColors(tester), CreationColorPalette.colors);
    });
  });

  group("every color picker offers the same palette", () {
    testWidgets("when creating an activity", (tester) async {
      final AppNavigator navigator = AppNavigator();
      Get.put<AppNavigator>(navigator);
      Get.put<CreateSubjectController>(
        CreateSubjectController(
          addSubjectUseCase: _UnusedAddSubject(),
          updateSubjectUseCase: _UnusedUpdateSubject(),
          appNavigator: navigator,
          achievementUnlockService: _UnusedAchievements(),
          analyticsService: _UnusedAnalytics(),
          category: TimeCategoryType.studying,
        ),
      );

      await _pumpPage(tester, const CreateSubjectPage());

      expect(find.byType(CreationColorPalette), findsOneWidget);
      expect(_shownColors(tester), CreationColorPalette.colors);
    });

    testWidgets("when creating a goal", (tester) async {
      final AppNavigator navigator = AppNavigator();
      Get.put<AppNavigator>(navigator);
      Get.put<CreateTaskController>(
        CreateTaskController(
          addDailyTaskUseCase: _UnusedAddDailyTask(),
          updateDailyTaskUseCase: _UnusedUpdateDailyTask(),
          appNavigator: navigator,
          achievementUnlockService: _UnusedAchievements(),
          ensureNotificationsEnabled: () async => true,
        ),
      );

      await _pumpPage(tester, const CreateTaskPage());

      expect(find.byType(CreationColorPalette), findsOneWidget);
      expect(_shownColors(tester), CreationColorPalette.colors);
    });

    testWidgets("when adding a schedule entry", (tester) async {
      Get.put<AppNavigator>(AppNavigator());

      await _pumpPage(tester, const AddScheduleEntryPage());

      expect(find.byType(CreationColorPalette), findsOneWidget);
      expect(_shownColors(tester), CreationColorPalette.colors);
    });
  });
}
