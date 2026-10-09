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

SubjectEntity _subject({
  required TimeCategoryType category,
  DateTime? createdAt,
  SubjectActivityType activityType = SubjectActivityType.daily,
}) => SubjectEntity(
  id: "subject-1",
  name: "Matéria",
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
  createdAt: createdAt,
  activityType: activityType,
);

Future<void> _pumpStats(
  WidgetTester tester,
  SubjectEntity subject, {
  Size size = const Size(430, 900),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  // The top bar's back button resolves the navigator while building.
  Get.put<AppNavigator>(AppNavigator());
  Get.put<SubjectStatsController>(
    buildStatsController(
      subject: subject,
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets("shows when the goal started instead of the session count", (
    tester,
  ) async {
    await _pumpStats(
      tester,
      _subject(
        category: TimeCategoryType.studying,
        createdAt: DateTime(2026, 9, 12, 8, 30),
      ),
    );

    expect(find.text("Início da meta"), findsOneWidget);
    expect(find.text("12/09/2026"), findsOneWidget);
    expect(find.text("Sessões"), findsNothing);
    // The other tiles stay where they were; the goal percentage lives in the
    // header, so it is not repeated as a tile.
    expect(find.text("Tempo estudado"), findsOneWidget);
    expect(find.text("Meta"), findsNothing);
    expect(find.text("Descanso"), findsOneWidget);
    expect(find.text("Frequência da atividade"), findsOneWidget);
    expect(find.text("Diária"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("reading replaces today's pages with the activity type", (
    tester,
  ) async {
    await _pumpStats(
      tester,
      _subject(
        category: TimeCategoryType.reading,
        createdAt: DateTime(2026, 1, 5),
      ),
    );

    expect(find.text("Páginas hoje"), findsNothing);
    expect(find.text("Frequência da atividade"), findsOneWidget);
    expect(find.text("Diária"), findsOneWidget);
    expect(find.text("Início da meta"), findsOneWidget);
    expect(find.text("05/01/2026"), findsOneWidget);
    expect(find.text("Sessões"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("hobbies show the start date without sessions or rest", (
    tester,
  ) async {
    await _pumpStats(
      tester,
      _subject(
        category: TimeCategoryType.hobbies,
        createdAt: DateTime(2026, 3, 1),
      ),
    );

    expect(find.text("Início da meta"), findsOneWidget);
    expect(find.text("01/03/2026"), findsOneWidget);
    expect(find.text("Sessões"), findsNothing);
    expect(find.text("Descanso"), findsNothing);
    expect(find.text("Frequência da atividade"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("shows when an activity is permanent", (tester) async {
    await _pumpStats(
      tester,
      _subject(
        category: TimeCategoryType.reading,
        activityType: SubjectActivityType.permanent,
      ),
    );

    expect(find.text("Frequência da atividade"), findsOneWidget);
    expect(find.text("Permanente"), findsOneWidget);
    expect(find.text("Páginas hoje"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("falls back to a dash when the subject has no creation date", (
    tester,
  ) async {
    await _pumpStats(tester, _subject(category: TimeCategoryType.exercises));

    expect(find.text("Início da meta"), findsOneWidget);
    expect(find.text("—"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("lays out on a narrow screen without overflowing", (
    tester,
  ) async {
    await _pumpStats(
      tester,
      _subject(
        category: TimeCategoryType.studying,
        createdAt: DateTime(2026, 12, 25),
      ),
      size: const Size(320, 640),
    );

    expect(find.text("25/12/2026"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test("goalStartDate is expressed in local time", () {
    final SubjectStatsController controller = buildStatsController(
      subject: _subject(
        category: TimeCategoryType.studying,
        createdAt: DateTime.utc(2026, 9, 13, 1),
      ),
      history: SubjectDailyHistoryService(localStorageService: _MemStorage()),
    );

    expect(controller.goalStartDate, isNotNull);
    expect(controller.goalStartDate!.isUtc, isFalse);
  });
}
