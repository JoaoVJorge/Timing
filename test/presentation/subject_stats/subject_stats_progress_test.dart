import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/subject_stats/subject_stats_controller.dart";
import "package:timing/presentation/subject_stats/subject_stats_page.dart";
import "package:timing/theme/theme.dart";

import "../../support/subject_stats_test_support.dart";

class _MemStorage implements AppLocalStorageService {
  final Map<LocalStorageKeys, Object?> _values = {};

  @override
  Future<T?> read<T>(LocalStorageKeys key) async => _values[key] as T?;

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async =>
      _values[key] = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const String _id = "subject-1";

SubjectEntity _subject({
  required TimeCategoryType category,
  required SubjectActivityType activityType,
  int totalSeconds = 0,
  int goalSeconds = 0,
  int currentPages = 0,
  int goalPages = 0,
  int focusSessionCount = 1,
}) => SubjectEntity(
  id: _id,
  name: "Atividade",
  category: category,
  colorValue: 0xFF2196F3,
  totalSeconds: totalSeconds,
  goalSeconds: goalSeconds,
  currentPages: currentPages,
  goalPages: goalPages,
  notes: "",
  iconName: "",
  restMinutes: 5,
  focusSessionCount: focusSessionCount,
  wallpaperIndex: 0,
  activityType: activityType,
);

/// A controller whose history already holds what was done today.
Future<SubjectStatsController> _controller(
  SubjectEntity subject, {
  int pagesToday = 0,
  int secondsToday = 0,
}) async {
  final SubjectDailyHistoryService history = SubjectDailyHistoryService(
    localStorageService: _MemStorage(),
  );
  await history.addPages(_id, pagesToday);
  await history.addFocusSeconds(_id, secondsToday);
  return buildStatsController(subject: subject, history: history);
}

Future<void> _pump(
  WidgetTester tester,
  SubjectStatsController controller,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 1600);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  Get.put<AppNavigator>(AppNavigator());
  Get.put<SubjectStatsController>(controller);

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

  group("a daily activity measures its goal by today", () {
    test(
      "reading: 8 pages over other days and 2 today, goal 10, is 20%",
      () async {
        final SubjectStatsController controller = await _controller(
          _subject(
            category: TimeCategoryType.reading,
            activityType: SubjectActivityType.daily,
            currentPages: 8,
            goalPages: 10,
          ),
          pagesToday: 2,
        );

        expect(controller.overviewCurrent, 2);
        expect(controller.progress, closeTo(0.2, 1e-9));
      },
    );

    test("time: only today's focus counts against the day's goal", () async {
      // 3 sessions of 30 minutes make a 90 minute day; 3 hours were studied
      // over the past days, and 15 minutes today.
      final SubjectStatsController controller = await _controller(
        _subject(
          category: TimeCategoryType.studying,
          activityType: SubjectActivityType.daily,
          totalSeconds: 3 * 3600,
          goalSeconds: 30 * 60,
          focusSessionCount: 3,
        ),
        secondsToday: 15 * 60,
      );

      expect(controller.overviewCurrent, 15 * 60);
      expect(controller.progress, closeTo(15 / 90, 1e-9));
    });

    test(
      "a day with nothing done yet is 0%, however much came before",
      () async {
        final SubjectStatsController controller = await _controller(
          _subject(
            category: TimeCategoryType.reading,
            activityType: SubjectActivityType.daily,
            currentPages: 40,
            goalPages: 10,
          ),
        );

        expect(controller.progress, 0);
      },
    );
  });

  group("a permanent activity keeps adding up", () {
    test("time: the running total counts against the total goal", () async {
      final SubjectStatsController controller = await _controller(
        _subject(
          category: TimeCategoryType.studying,
          activityType: SubjectActivityType.permanent,
          totalSeconds: 3600,
          goalSeconds: 7200,
        ),
        secondsToday: 900,
      );

      expect(controller.overviewCurrent, 3600);
      expect(controller.progress, closeTo(0.5, 1e-9));
    });

    test("reading: pages read so far count, not just today's", () async {
      final SubjectStatsController controller = await _controller(
        _subject(
          category: TimeCategoryType.reading,
          activityType: SubjectActivityType.permanent,
          currentPages: 8,
          goalPages: 10,
        ),
        pagesToday: 2,
      );

      expect(controller.progress, closeTo(0.8, 1e-9));
    });
  });

  group("the stats screen", () {
    testWidgets("shows today's percentage under a Today label, no Goal tile", (
      tester,
    ) async {
      await _pump(
        tester,
        await _controller(
          _subject(
            category: TimeCategoryType.reading,
            activityType: SubjectActivityType.daily,
            currentPages: 8,
            goalPages: 10,
          ),
          pagesToday: 2,
        ),
      );

      expect(find.text("Hoje"), findsOneWidget);
      expect(find.text("Total"), findsNothing);
      expect(find.text("20%"), findsOneWidget);
      expect(find.text("80%"), findsNothing);
      // The percentage is not repeated as a tile of the overview.
      expect(find.text("Meta"), findsNothing);
      // The lifetime numbers stay in the overview.
      expect(find.text("Total de páginas"), findsOneWidget);
      expect(find.text("Páginas hoje"), findsNothing);
      expect(find.text("Frequência da atividade"), findsOneWidget);
      expect(find.text("Diária"), findsOneWidget);
    });

    testWidgets("a permanent activity keeps the Total label and its total", (
      tester,
    ) async {
      await _pump(
        tester,
        await _controller(
          _subject(
            category: TimeCategoryType.reading,
            activityType: SubjectActivityType.permanent,
            currentPages: 8,
            goalPages: 10,
          ),
          pagesToday: 2,
        ),
      );

      expect(find.text("Total"), findsOneWidget);
      expect(find.text("80%"), findsOneWidget);
      expect(find.text("Meta"), findsNothing);
      expect(find.text("Frequência da atividade"), findsOneWidget);
      expect(find.text("Permanente"), findsOneWidget);
      expect(find.text("Páginas hoje"), findsNothing);
    });
  });
}
