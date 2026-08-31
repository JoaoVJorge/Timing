import "package:dartz/dartz.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/profile_stats_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/achievements/achievements_controller.dart";

class AchievementUnlockService {
  AchievementUnlockService({
    required this.getProfileStatsUseCase,
    required this.getDailyTasksUseCase,
    required this.dailyProgressService,
    required this.localStorageService,
  });

  static const int _notificationId = 2001;
  static const String _channelId = "achievements";
  static const String _channelName = "Achievements";
  static const String _channelDescription = "Alerts when achievements unlock";
  static const String _notificationIcon = "ic_notification";

  final GetProfileStatsUseCase getProfileStatsUseCase;
  final GetDailyTasksUseCase getDailyTasksUseCase;
  final DailyProgressService dailyProgressService;
  final AppLocalStorageService localStorageService;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initializedNotifications = false;
  bool _isChecking = false;
  bool _notificationsEnabled = true;

  bool get _isSupported => GetPlatform.isAndroid;

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
  }

  Future<void> initializeBaselineIfNeeded() async {
    final Set<int>? announced = await _readAnnouncedIds();
    if (announced != null) {
      return;
    }

    final Set<int>? current = await _currentUnlockedIds();
    if (current == null) {
      return;
    }
    await _writeAnnouncedIds(current);
  }

  Future<void> checkForNewUnlocks() async {
    if (_isChecking) {
      return;
    }

    _isChecking = true;
    try {
      final Set<int>? current = await _currentUnlockedIds();
      if (current == null) {
        return;
      }

      final Set<int>? announced = await _readAnnouncedIds();
      if (announced == null) {
        await _writeAnnouncedIds(current);
        return;
      }

      final List<int> newlyUnlocked = current.difference(announced).toList()
        ..sort();
      if (newlyUnlocked.isEmpty) {
        return;
      }

      await _writeAnnouncedIds({...announced, ...newlyUnlocked});
      await _showUnlockNotification(newlyUnlocked.first);
    } finally {
      _isChecking = false;
    }
  }

  Future<Set<int>?> _currentUnlockedIds() async {
    final statsFuture = getProfileStatsUseCase();
    final tasksFuture = getDailyTasksUseCase();
    final Either<AppError, ProfileStatsEntity> statsResult = await statsFuture;
    final Either<AppError, List<DailyTaskEntity>> tasksResult =
        await tasksFuture;

    ProfileStatsEntity? stats;
    List<DailyTaskEntity>? tasks;
    statsResult.fold((error) => null, (value) => stats = value);
    tasksResult.fold((error) => null, (value) => tasks = value);
    if (stats == null || tasks == null) {
      return null;
    }

    final int focusMinutes = stats!.totalFocusSeconds ~/ 60;
    final int totalSessions = dailyProgressService.allProgress.fold<int>(
      0,
      (total, progress) => total + progress.sessions,
    );
    final int totalPages = stats!.readingTotalPages;
    final int completedGoalDays = tasks!.fold<int>(
      0,
      (total, task) => total + task.completedDays,
    );
    final int activeDays = dailyProgressService.allProgress
        .where((progress) => progress.focusSeconds > 0)
        .length;
    final bool hasGoal = tasks!.isNotEmpty;
    final bool hasCompletedGoal = tasks!.any((task) => task.isCompleted);
    final bool allGoalsDoneToday =
        tasks!.isNotEmpty && tasks!.every((task) => task.isDoneForCurrentCycle);

    final Set<int> ids = {
      if (focusMinutes > 0) 1,
      if (focusMinutes >= 25) 2,
      if (focusMinutes >= 60) 3,
      if (focusMinutes >= 120) 4,
      if (totalSessions >= 3) 5,
      if (focusMinutes >= 600) 6,
      if (activeDays >= 5) 7,
      if (totalSessions >= 10) 8,
      if (activeDays >= 7) 9,
      if (focusMinutes >= 1500) 10,
      if (stats!.studyingTotalSeconds > 0) 11,
      if (totalSessions >= 3) 12,
      if (totalSessions >= 5) 13,
      if (totalSessions >= 10) 14,
      if (stats!.hasTopStudyingSubject) 15,
      if (stats!.studyingTotalSeconds >= 18000) 16,
      if (totalSessions >= 15) 17,
      if (stats!.totalFocusGoalSeconds > 0) 18,
      if (stats!.studyingTotalSeconds >= 72000) 19,
      if (stats!.studyingTotalSeconds >= 180000) 20,
      if (totalPages >= 1) 21,
      if (totalPages >= 10) 22,
      if (totalPages >= 25) 23,
      if (totalPages >= 50) 24,
      if (totalPages >= 100) 25,
      if (totalPages >= 150) 26,
      if (totalPages >= 250) 27,
      if (totalPages >= 300) 28,
      if (totalPages >= 500) 29,
      if (totalPages >= 1000) 30,
      if (hasGoal) 31,
      if (hasCompletedGoal) 32,
      if (allGoalsDoneToday) 33,
      if (completedGoalDays >= 3) 34,
      if (completedGoalDays >= 5) 35,
      if (completedGoalDays >= 10) 36,
      if (completedGoalDays >= 15) 37,
      if (completedGoalDays >= 20) 38,
      if (completedGoalDays >= 30) 39,
      if (completedGoalDays >= 50) 40,
      if (stats!.exercisesTotalSeconds > 0) 45,
      if (stats!.exercisesTotalSeconds >= 1800) 46,
      if (stats!.hobbiesTotalSeconds > 0) 47,
      if (stats!.hobbiesTotalSeconds >= 1800) 48,
      if (stats!.exercisesTotalSeconds >= 7200) 49,
    };

    if (ids.length >= 25) {
      ids.add(50);
    }
    return ids;
  }

  Future<Set<int>?> _readAnnouncedIds() async {
    final List<String>? saved = await localStorageService.read<List<String>?>(
      LocalStorageKeys.announcedAchievementIds,
    );
    return saved?.map((id) => int.tryParse(id)).whereType<int>().toSet();
  }

  Future<void> _writeAnnouncedIds(Set<int> ids) async {
    final List<int> sortedIds = ids.toList()..sort();
    final List<String> serialized = sortedIds
        .map((id) => id.toString())
        .toList();
    await localStorageService.write<List<String>>(
      LocalStorageKeys.announcedAchievementIds,
      serialized,
    );
  }

  Future<void> _ensureNotificationsInitialized() async {
    if (_initializedNotifications) {
      return;
    }

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings(_notificationIcon),
    );
    await _plugin.initialize(settings: settings);
    _initializedNotifications = true;
  }

  Future<void> _showUnlockNotification(int achievementId) async {
    if (!_isSupported || !_notificationsEnabled) {
      return;
    }

    final context = Get.context;
    if (context == null) {
      return;
    }
    final String notificationTitle =
        context.l10n.achievementUnlockedNotificationTitle;
    final String achievementTitle = achievementTitleForId(
      context.l10n,
      achievementId,
    );

    try {
      await _ensureNotificationsInitialized();
      final bool notificationsAllowed =
          await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
      if (!notificationsAllowed) {
        return;
      }
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            autoCancel: true,
            showWhen: true,
            icon: _notificationIcon,
          );
      await _plugin.show(
        id: _notificationId,
        title: notificationTitle,
        body: achievementTitle,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
    } catch (_) {
      // Progress should never fail because achievement notifications are off.
    }
  }
}
