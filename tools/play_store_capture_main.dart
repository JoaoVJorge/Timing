// Run on a disposable iOS simulator to capture the app's actual Flutter pages.
// flutter run -d <simulator-id> -t tools/play_store_capture_main.dart \
//   --dart-define=STORE_LOCALE=pt-BR
import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/app/app_widget.dart";
import "package:timing/app/bindings/app_bindings.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/active_timer_session_entity.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/presentation/main_navigation/enums/bottom_nav_button_type.dart";
import "package:timing/presentation/main_navigation/main_navigation_controller.dart";
import "package:timing/presentation/schedule/schedule_controller.dart";

const String captureLocale = String.fromEnvironment(
  "STORE_LOCALE",
  defaultValue: "pt-BR",
);
final GlobalKey captureKey = GlobalKey(debugLabel: "storeCaptureRoot");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBindings().dependencies();
  await _seedDemo(captureLocale == "pt-BR");
  runApp(
    RepaintBoundary(
      key: captureKey,
      child: const AppWidget(initialRoute: AppRoutes.mainNavigation),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_capturePages());
  });
}

Future<void> _seedDemo(bool pt) async {
  final DateTime today = DateTime.now();
  final AppLocalStorageService storage = Get.find();
  final List<SubjectEntity> subjects = [
    _subject(
      "math",
      pt ? "Matemática" : "Mathematics",
      TimeCategoryType.studying,
      0xFF4E91C5,
      11880,
      3600,
      "graduate",
    ),
    _subject(
      "chem",
      pt ? "Química" : "Chemistry",
      TimeCategoryType.studying,
      0xFF429CB1,
      9000,
      3600,
      "book",
    ),
    _subject(
      "exercise",
      pt ? "Exercícios" : "Exercise",
      TimeCategoryType.exercises,
      0xFF6CA593,
      5400,
      1800,
      "bicycle",
    ),
    _subject(
      "reading",
      pt ? "Leitura de ciência" : "Science reading",
      TimeCategoryType.reading,
      0xFF7C9CB0,
      3600,
      0,
      "open-book",
      currentPages: 84,
      goalPages: 120,
    ),
  ];
  final String todayKey = DailyProgressService.dateKey(today);
  final List<DailyTaskEntity> tasks = [
    DailyTaskEntity(
      id: "goal-math",
      name: pt ? "Revisar Matemática" : "Review Mathematics",
      colorValue: 0xFF4E91C5,
      targetDays: 7,
      completedDates: [todayKey],
    ),
    DailyTaskEntity(
      id: "goal-chem",
      name: pt ? "Exercícios de Química" : "Chemistry exercises",
      colorValue: 0xFF429CB1,
      targetDays: 7,
      completedDates: const [],
    ),
    DailyTaskEntity(
      id: "goal-read",
      name: pt ? "Ler 20 páginas" : "Read 20 pages",
      colorValue: 0xFF7C9CB0,
      targetDays: 7,
      completedDates: [todayKey],
    ),
  ];
  final int weekday = today.weekday;
  final DateTime activeFrom = today.subtract(const Duration(days: 21));
  final List<ScheduleEntryEntity> schedule = [
    _entry(
      "schedule-math",
      pt ? "Estudo de Matemática" : "Mathematics study",
      weekday,
      8 * 60,
      9 * 60,
      0xFF4E91C5,
      activeFrom,
    ),
    _entry(
      "schedule-chem",
      pt ? "Exercícios de Química" : "Chemistry exercises",
      weekday,
      10 * 60 + 30,
      11 * 60 + 15,
      0xFF429CB1,
      activeFrom,
    ),
    _entry(
      "schedule-read",
      pt ? "Leitura" : "Reading",
      weekday,
      14 * 60,
      14 * 60 + 30,
      0xFF7C9CB0,
      activeFrom,
    ),
  ];

  final Map<String, dynamic> daily = {};
  final Map<String, dynamic> subjectDaily = {
    for (final subject in subjects) subject.id: <String, dynamic>{},
  };
  final List<ActivityEntryEntity> history = [];
  final List<int> minutes = [38, 54, 41, 66, 58, 74, 83];
  for (int i = 0; i < 7; i++) {
    final DateTime date = today.subtract(Duration(days: 6 - i));
    final String dateKey = DailyProgressService.dateKey(date);
    final int mathMinutes = i == 6 ? 33 : (minutes[i] * 0.55).round();
    final int chemMinutes = i == 6 ? 31 : (minutes[i] * 0.25).round();
    final int exerciseMinutes = minutes[i] - mathMinutes - chemMinutes;
    daily[dateKey] = DailyProgressEntity(
      focusSeconds: minutes[i] * 60,
      sessions: i == 6 ? 3 : 2,
      pages: i == 6 ? 12 : 8,
    ).toMap();
    (subjectDaily["math"]
        as Map<String, dynamic>)[dateKey] = DailyProgressEntity(
      focusSeconds: mathMinutes * 60,
      sessions: 1,
    ).toMap();
    (subjectDaily["chem"]
        as Map<String, dynamic>)[dateKey] = DailyProgressEntity(
      focusSeconds: chemMinutes * 60,
      sessions: 1,
    ).toMap();
    (subjectDaily["exercise"] as Map<String, dynamic>)[dateKey] =
        DailyProgressEntity(focusSeconds: exerciseMinutes * 60).toMap();
    (subjectDaily["reading"] as Map<String, dynamic>)[dateKey] =
        DailyProgressEntity(pages: i == 6 ? 12 : 8).toMap();
    history.add(
      ActivityEntryEntity(
        id: "history-$i-math",
        category: TimeCategoryType.studying,
        subjectId: "math",
        subjectName: subjects[0].name,
        timestamp: date,
        seconds: mathMinutes * 60,
      ),
    );
    history.add(
      ActivityEntryEntity(
        id: "history-$i-chem",
        category: TimeCategoryType.studying,
        subjectId: "chem",
        subjectName: subjects[1].name,
        timestamp: date,
        seconds: chemMinutes * 60,
      ),
    );
    history.add(
      ActivityEntryEntity(
        id: "history-$i-exercise",
        category: TimeCategoryType.exercises,
        subjectId: "exercise",
        subjectName: subjects[2].name,
        timestamp: date,
        seconds: exerciseMinutes * 60,
      ),
    );
    history.add(
      ActivityEntryEntity(
        id: "history-$i-read",
        category: TimeCategoryType.reading,
        subjectId: "reading",
        subjectName: subjects[3].name,
        timestamp: date,
        pages: i == 6 ? 12 : 8,
      ),
    );
  }

  await storage.write(
    LocalStorageKeys.subjects,
    jsonEncode(subjects.map((s) => s.toMap()).toList()),
  );
  await storage.write(
    LocalStorageKeys.dailyTasks,
    jsonEncode(tasks.map((t) => t.toMap()).toList()),
  );
  await storage.write(
    LocalStorageKeys.scheduleEntries,
    jsonEncode(schedule.map((e) => e.toMap()).toList()),
  );
  await storage.write(LocalStorageKeys.dailyProgress, jsonEncode(daily));
  await storage.write(
    LocalStorageKeys.subjectDailyHistory,
    jsonEncode(subjectDaily),
  );
  await storage.write(
    LocalStorageKeys.activityHistory,
    jsonEncode(history.map((e) => e.toMap()).toList()),
  );

  final AppController app = Get.find();
  app.userName.value = pt ? "Estudante" : "Student";
  app.languageCode.value = pt ? "pt" : "en";
  app.isDarkMode.value = false;
  app.accentColor.value = const Color(0xFF0AACC2);
  await Get.find<DailyProgressService>().load();
  await Get.find<SubjectDailyHistoryService>().load();
  await Get.find<ActivityHistoryService>().load();
  await Get.find<ScheduleController>().loadEntries();
  await Get.find<LastActivityService>().record(
    subjects[0].name,
    subjectId: subjects[0].id,
  );
}

SubjectEntity _subject(
  String id,
  String name,
  TimeCategoryType category,
  int color,
  int seconds,
  int goalSeconds,
  String icon, {
  int currentPages = 0,
  int goalPages = 0,
}) => SubjectEntity(
  id: id,
  name: name,
  category: category,
  colorValue: color,
  totalSeconds: seconds,
  goalSeconds: goalSeconds,
  currentPages: currentPages,
  goalPages: goalPages,
  notes: "",
  iconName: icon,
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
  activityType: category == TimeCategoryType.studying
      ? SubjectActivityType.daily
      : SubjectActivityType.permanent,
);

ScheduleEntryEntity _entry(
  String id,
  String title,
  int weekday,
  int start,
  int end,
  int color,
  DateTime activeFrom,
) => ScheduleEntryEntity(
  id: id,
  title: title,
  weekday: weekday,
  startMinutes: start,
  endMinutes: end,
  colorValue: color,
  activeFrom: activeFrom,
);

Future<void> _capturePages() async {
  await _save("home");
  unawaited(
    Get.toNamed<void>(
          AppRoutes.category,
          arguments: TimeCategoryType.studying,
        ) ??
        Future<void>.value(),
  );
  await _save("subjects");
  unawaited(
    Get.offAllNamed<void>(AppRoutes.mainNavigation) ?? Future<void>.value(),
  );
  await Future<void>.delayed(const Duration(milliseconds: 800));
  unawaited(
    Get.toNamed<void>(
          AppRoutes.category,
          arguments: TimeCategoryType.reading,
        ) ??
        Future<void>.value(),
  );
  await _save("reading");
  unawaited(Get.offNamed<void>(AppRoutes.dailyGoals) ?? Future<void>.value());
  await _save("goals");
  unawaited(
    Get.offAllNamed<void>(AppRoutes.mainNavigation) ?? Future<void>.value(),
  );
  await Future<void>.delayed(const Duration(milliseconds: 800));
  Get.find<MainNavigationController>().onTapBottomBarButton(
    BottomNavButtonType.progress,
  );
  await _save("progress");
  unawaited(Get.toNamed<void>(AppRoutes.achievements) ?? Future<void>.value());
  await _save("achievements");
  unawaited(Get.offNamed<void>(AppRoutes.schedule) ?? Future<void>.value());
  await _save("schedule");
  final SubjectEntity timerSubject = _subject(
    "math",
    captureLocale == "pt-BR" ? "Matemática" : "Mathematics",
    TimeCategoryType.studying,
    0xFF4E91C5,
    11880,
    3600,
    "graduate",
  );
  unawaited(
    Get.offNamed<void>(
          AppRoutes.timer,
          arguments: TimerRouteArguments(
            subject: timerSubject,
            restoredSession: ActiveTimerSessionEntity(
              subject: timerSubject,
              sessionSeconds: 24 * 60,
              breakCountdownSeconds: 36 * 60,
              restCountdownSeconds: 0,
              isRunning: true,
              isResting: false,
              completedFocusSections: 0,
              persistedSeconds: 0,
              todayFocusSecondsAtSessionStart: 33 * 60,
              capturedAt: DateTime.now().toUtc(),
            ),
          ),
        ) ??
        Future<void>.value(),
  );
  await _save("timer");
  debugPrint("STORE_CAPTURE_DONE $captureLocale");
}

Future<void> _save(String name) async {
  await Future<void>.delayed(const Duration(seconds: 3));
  await WidgetsBinding.instance.endOfFrame;
  final boundary =
      captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError("Capture boundary is unavailable for $name");
  }
  final ui.Image image = await boundary.toImage(pixelRatio: 3);
  final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (data == null) {
    throw StateError("Could not encode $name");
  }
  final Directory out = Directory(
    "${Directory.systemTemp.path}/timing-store-capture",
  )..createSync(recursive: true);
  final File file = File("${out.path}/$captureLocale-$name.png");
  await file.writeAsBytes(data.buffer.asUint8List());
  debugPrint("STORE_CAPTURE_SAVED ${file.path}");
}
