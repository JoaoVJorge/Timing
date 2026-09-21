import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/data/data_sources/friends_data_source.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/data/data_sources/schedule_data_source.dart";
import "package:timing/core/data/data_sources/subjects_data_source.dart";

/// Flushes datasets whose remote sync failed earlier (tracked by
/// [PendingSyncStore]) by re-pushing the current local state. Meant to run
/// once on authenticated startup so offline edits converge without waiting for
/// the user's next online save.
class SyncReconciliationService {
  const SyncReconciliationService({
    required this._subjectsDataSource,
    required this._scheduleDataSource,
    required this._dailyTasksDataSource,
    required this._activityDataSource,
    required this._groupsDataSource,
    required this._friendsDataSource,
  });

  final SubjectsDataSource _subjectsDataSource;
  final ScheduleDataSource _scheduleDataSource;
  final DailyTasksDataSource _dailyTasksDataSource;
  final ActivityDataSource _activityDataSource;
  final GroupsDataSource _groupsDataSource;
  final FriendsDataSource _friendsDataSource;

  Future<void> flushPending() async {
    await _subjectsDataSource.flushPendingSync();
    await _scheduleDataSource.flushPendingSync();
    await _dailyTasksDataSource.flushPendingSync();
    await _activityDataSource.flushPendingSync();
    await _groupsDataSource.flushPendingSync();
    await _friendsDataSource.flushPendingSync();
  }
}
