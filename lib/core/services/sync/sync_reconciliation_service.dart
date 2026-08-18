import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
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
  });

  final SubjectsDataSource _subjectsDataSource;
  final ScheduleDataSource _scheduleDataSource;
  final DailyTasksDataSource _dailyTasksDataSource;

  Future<void> flushPending() async {
    await _subjectsDataSource.flushPendingSync();
    await _scheduleDataSource.flushPendingSync();
    await _dailyTasksDataSource.flushPendingSync();
  }
}
