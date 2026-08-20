import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

class _Dummy {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _DummyStorage extends _Dummy implements AppLocalStorageService {}

class _DummySupabase extends _Dummy implements SupabaseService {}

class _DummyLogger extends _Dummy implements AppLoggerService {}

class _DummyPendingSync extends _Dummy implements PendingSyncStore {}

DailyTaskEntity _task({
  required String id,
  required List<String> completedDates,
  DateTime? updatedAt,
}) => DailyTaskEntity(
  id: id,
  name: "Estudar",
  colorValue: 1,
  targetDays: 30,
  completedDates: completedDates,
  sequenceType: DailyTaskSequenceType.intense,
  updatedAt: updatedAt,
);

void main() {
  final DailyTasksDataSource dataSource = DailyTasksDataSource(
    localStorageService: _DummyStorage(),
    supabaseService: _DummySupabase(),
    logger: _DummyLogger(),
    pendingSyncStore: _DummyPendingSync(),
  );

  group("DailyTasksDataSource.mergeTasks last-write-wins", () {
    test("keeps a fresh local change over a stale remote copy", () {
      final DateTime now = DateTime.now().toUtc();
      // Local has just marked yesterday (newer); remote is still the old copy.
      final DailyTaskEntity local = _task(
        id: "1",
        completedDates: const ["2026-08-15", "2026-08-16", "2026-08-17"],
        updatedAt: now,
      );
      final DailyTaskEntity staleRemote = _task(
        id: "1",
        completedDates: const ["2026-08-16", "2026-08-17"],
        updatedAt: now.subtract(const Duration(minutes: 5)),
      );

      final List<DailyTaskEntity> merged = dataSource.mergeTasks(
        localTasks: [local],
        remoteTasks: [staleRemote],
      );

      expect(merged.single.completedDates, local.completedDates);
    });

    test("takes the remote copy when it is newer (e.g. another device)", () {
      final DateTime now = DateTime.now().toUtc();
      final DailyTaskEntity local = _task(
        id: "1",
        completedDates: const ["2026-08-16"],
        updatedAt: now.subtract(const Duration(minutes: 5)),
      );
      final DailyTaskEntity newerRemote = _task(
        id: "1",
        completedDates: const ["2026-08-16", "2026-08-17"],
        updatedAt: now,
      );

      final List<DailyTaskEntity> merged = dataSource.mergeTasks(
        localTasks: [local],
        remoteTasks: [newerRemote],
      );

      expect(merged.single.completedDates, newerRemote.completedDates);
    });

    test("local change with a timestamp beats a remote with none", () {
      final DailyTaskEntity local = _task(
        id: "1",
        completedDates: const ["2026-08-16", "2026-08-17"],
        updatedAt: DateTime.now().toUtc(),
      );
      final DailyTaskEntity legacyRemote = _task(
        id: "1",
        completedDates: const ["2026-08-16"],
      );

      final List<DailyTaskEntity> merged = dataSource.mergeTasks(
        localTasks: [local],
        remoteTasks: [legacyRemote],
      );

      expect(merged.single.completedDates, local.completedDates);
    });

    test("brings in remote-only tasks", () {
      final DailyTaskEntity local = _task(
        id: "1",
        completedDates: const ["2026-08-16"],
        updatedAt: DateTime.now().toUtc(),
      );
      final DailyTaskEntity remoteOnly = _task(
        id: "2",
        completedDates: const ["2026-08-16"],
        updatedAt: DateTime.now().toUtc(),
      );

      final List<DailyTaskEntity> merged = dataSource.mergeTasks(
        localTasks: [local],
        remoteTasks: [remoteOnly],
      );

      expect(merged.map((task) => task.id).toSet(), {"1", "2"});
    });
  });
}
