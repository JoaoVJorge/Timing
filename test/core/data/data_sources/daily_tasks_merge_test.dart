import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
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

class _SignedInSupabase extends _Dummy implements SupabaseService {
  @override
  String? get currentUserId => "user-1";
}

class _DummyLogger extends _Dummy implements AppLoggerService {}

class _DummyPendingSync extends _Dummy implements PendingSyncStore {}

DailyTaskEntity _task({
  required String id,
  required List<String> completedDates,
  DateTime? updatedAt,
  String? groupId,
  String? groupActivityId,
}) => DailyTaskEntity(
  id: id,
  name: "Estudar",
  colorValue: 1,
  targetDays: 30,
  completedDates: completedDates,
  sequenceType: DailyTaskSequenceType.intense,
  goalType: DailyTaskGoalType.daily,
  updatedAt: updatedAt,
  groupId: groupId,
  groupActivityId: groupActivityId,
);

void main() {
  final DailyTasksRepository dataSource = DailyTasksRepository(
    dailyTasksDataSource: DailyTasksDataSource(
      supabaseService: _DummySupabase(),
      logger: AppLoggerService(),
    ),
    localStorageService: _DummyStorage(),
    logger: _DummyLogger(),
    pendingSyncStore: _DummyPendingSync(),
  );

  test("remote deletes stay disabled before the first complete read", () {
    final nonHydratedDataSource = DailyTasksRepository(
      dailyTasksDataSource: DailyTasksDataSource(
        supabaseService: _SignedInSupabase(),
        logger: AppLoggerService(),
      ),
      localStorageService: _DummyStorage(),
      logger: _DummyLogger(),
      pendingSyncStore: _DummyPendingSync(),
    );

    expect(nonHydratedDataSource.canDeleteRemoteTasks("user-1"), isFalse);
  });

  group("DailyTasksRepository.mergeTasks last-write-wins", () {
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

    test(
      "repairs old group goals that were cached without groupActivityId",
      () {
        final DateTime now = DateTime.now().toUtc();
        final DailyTaskEntity legacyLocal = _task(
          id: "local-random-id",
          completedDates: const ["2026-08-25"],
          updatedAt: now,
          groupId: "group-123",
        );
        final DailyTaskEntity linkedRemote = _task(
          id: "grp_activity-123",
          completedDates: const [],
          updatedAt: now.subtract(const Duration(minutes: 5)),
          groupId: "group-123",
          groupActivityId: "activity-123",
        );

        final List<DailyTaskEntity> merged = dataSource.mergeTasks(
          localTasks: [legacyLocal],
          remoteTasks: [linkedRemote],
        );

        expect(merged, hasLength(1));
        expect(merged.single.id, "grp_activity-123");
        expect(merged.single.groupActivityId, "activity-123");
        expect(merged.single.completedDates, ["2026-08-25"]);
      },
    );
  });

  group("DailyTasksRepository.mergeTasks deletions made elsewhere", () {
    final DailyTaskEntity kept = _task(id: "kept", completedDates: const []);

    test("drops a goal the backend once held and no longer does", () {
      final List<DailyTaskEntity> merged = dataSource.mergeTasks(
        localTasks: [
          kept,
          _task(id: "deleted", completedDates: const []),
        ],
        remoteTasks: [kept],
        syncedIds: {"kept", "deleted"},
      );

      expect(merged.map((task) => task.id), ["kept"]);
    });

    test("keeps a goal created here that was never uploaded", () {
      final List<DailyTaskEntity> merged = dataSource.mergeTasks(
        localTasks: [
          kept,
          _task(id: "new", completedDates: const []),
        ],
        remoteTasks: [kept],
        syncedIds: {"kept"},
      );

      expect(merged.map((task) => task.id).toSet(), {"kept", "new"});
    });

    test("drops a leftover group goal the backend does not hold", () {
      final List<DailyTaskEntity> merged = dataSource.mergeTasks(
        localTasks: [
          kept,
          _task(
            id: "grp_activity-9",
            completedDates: const ["2026-08-25"],
            groupId: "left-group",
            groupActivityId: "activity-9",
          ),
        ],
        remoteTasks: [kept],
      );

      expect(merged.map((task) => task.id), ["kept"]);
    });

    test("an empty read never drops what this device holds", () {
      final List<DailyTaskEntity> merged = dataSource.mergeTasks(
        localTasks: [kept],
        remoteTasks: const [],
        syncedIds: {"kept"},
      );

      expect(merged.map((task) => task.id), ["kept"]);
    });
  });
}
