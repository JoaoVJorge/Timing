import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/subject_stats/subject_stats_controller.dart";
import "package:timing/presentation/subject_stats/subject_stats_page.dart";
import "package:timing/theme/theme.dart";

import "../../support/subject_stats_test_support.dart";

class _MemStorage implements AppLocalStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

SubjectEntity _subject(TimeCategoryType category) => SubjectEntity(
  id: "subject-1",
  name: "Atividade",
  category: category,
  colorValue: 0xFF2196F3,
  totalSeconds: 3600,
  goalSeconds: 1800,
  currentPages: 10,
  goalPages: 100,
  notes: "",
  iconName: "",
  restMinutes: 5,
  focusSessionCount: 3,
  wallpaperIndex: 0,
);

Future<void> _pumpStats(WidgetTester tester, TimeCategoryType category) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 1600);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  // The top bar's back button resolves the navigator while building.
  Get.put<AppNavigator>(AppNavigator());
  Get.put<SubjectStatsController>(
    buildStatsController(
      subject: _subject(category),
      history: SubjectDailyHistoryService(localStorageService: _MemStorage()),
    ),
  );

  await tester.pumpWidget(
    GetMaterialApp(
      locale: const Locale("pt"),
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const SubjectStatsPage(),
    ),
  );
  await tester.pump();
}

/// The unit sits in a rich-text headline, so it needs `findRichText`.
Finder _headlineUnit(String unit) =>
    find.textContaining(unit, findRichText: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets("studying keeps calling its time studied", (tester) async {
    await _pumpStats(tester, TimeCategoryType.studying);

    expect(find.text("Tempo estudado"), findsOneWidget);
    expect(_headlineUnit("estudados"), findsOneWidget);
  });

  testWidgets("exercises talk about time exercised, never studied", (
    tester,
  ) async {
    await _pumpStats(tester, TimeCategoryType.exercises);

    expect(find.text("Tempo exercitado"), findsOneWidget);
    expect(_headlineUnit("exercitados"), findsOneWidget);
    expect(find.text("Tempo estudado"), findsNothing);
    expect(_headlineUnit("estudados"), findsNothing);
  });

  testWidgets("hobbies talk about time practiced, never studied", (
    tester,
  ) async {
    await _pumpStats(tester, TimeCategoryType.hobbies);

    expect(find.text("Tempo praticado"), findsOneWidget);
    expect(_headlineUnit("praticados"), findsOneWidget);
    expect(find.text("Tempo estudado"), findsNothing);
    expect(_headlineUnit("estudados"), findsNothing);
  });

  testWidgets("reading keeps counting time read and pages read", (
    tester,
  ) async {
    await _pumpStats(tester, TimeCategoryType.reading);

    expect(find.text("Tempo lido"), findsOneWidget);
    expect(_headlineUnit("lidas"), findsOneWidget);
    expect(find.text("Tempo estudado"), findsNothing);
  });
}
