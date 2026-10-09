import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/data/repositories/schedule_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/services/google_calendar/google_calendar_service.dart";

/// Flushes datasets whose remote sync failed earlier (tracked by
/// [PendingSyncStore]) by re-pushing the current local state. Meant to run
/// once on authenticated startup so offline edits converge without waiting for
/// the user's next online save.
class SyncReconciliationService {
  const SyncReconciliationService({
    required this._subjectsRepository,
    required this._scheduleRepository,
    required this._dailyTasksRepository,
    required this._activityRepository,
    required this._groupsRepository,
    required this._friendsRepository,
    GoogleCalendarService? googleCalendarService,
  }) : _googleCalendar = googleCalendarService;

  final GoogleCalendarService? _googleCalendar;
  final SubjectsRepository _subjectsRepository;
  final ScheduleRepository _scheduleRepository;
  final DailyTasksRepository _dailyTasksRepository;
  final ActivityRepository _activityRepository;
  final GroupsRepository _groupsRepository;
  final FriendsRepository _friendsRepository;

  Future<void> flushPending() async {
    await _subjectsRepository.flushPendingSync();
    await _scheduleRepository.flushPendingSync();
    await _googleCalendar?.refresh();
    await _dailyTasksRepository.flushPendingSync();
    await _activityRepository.flushPendingSync();
    await _groupsRepository.flushPendingSync();
    await _friendsRepository.flushPendingSync();
  }
}
