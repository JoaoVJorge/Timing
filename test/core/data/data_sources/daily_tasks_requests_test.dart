import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

DailyTaskEntity _task(String id, {List<String> done = const []}) =>
    DailyTaskEntity(
      id: id,
      name: "Meta $id",
      colorValue: 1,
      targetDays: 10,
      completedDates: done,
      groupId: id.startsWith("grp_") ? "g1" : null,
      groupActivityId: id.startsWith("grp_") ? "ga1" : null,
    );

Map<String, dynamic> _row(DailyTaskEntity t) => {
  "id": t.id,
  "user_id": "user-1",
  "name": t.name,
  "color_value": t.colorValue,
  "target_days": t.targetDays,
  "completed_dates": t.completedDates,
  "goal_type": "total",
  "sequence_type": "casual",
  "group_id": t.groupId,
  "group_activity_id": t.groupActivityId,
  "updated_at": "2026-09-20T00:00:00Z",
};

class _Rig {
  _Rig() {
    backend = TestBackend((request) async {
      requests.add(
        "${request.method} ${Uri.decodeQueryComponent(request.url.query)}",
      );
      if (request.method == "GET") {
        return jsonResponse(request, remote.map(_row).toList());
      }
      return http.Response(
        "",
        request.method == "DELETE" ? 204 : 201,
        request: request,
      );
    });
    store = PendingSyncStore(localStorageService: storage);
    dataSource = DailyTasksDataSource(
      localStorageService: storage,
      supabaseService: TestSupabaseService(backend.client),
      logger: AppLoggerService(),
      pendingSyncStore: store,
    );
  }

  final MemoryStorage storage = MemoryStorage();
  final List<String> requests = [];
  List<DailyTaskEntity> remote = [];
  late final TestBackend backend;
  late final PendingSyncStore store;
  late final DailyTasksDataSource dataSource;

  void seedLocal(List<DailyTaskEntity> tasks) {
    storage.data[LocalStorageKeys.dailyTasks] = jsonEncode(
      tasks.map((t) => t.toMap()).toList(),
    );
  }

  /// A save, then waiting for its background upload to finish.
  Future<void> save(List<DailyTaskEntity> tasks) async {
    await dataSource.saveTasks(tasks);
    await pumpEventQueue();
  }

  List<String> writes(String method) =>
      requests.where((r) => r.startsWith(method)).toList();
}

void main() {
  late _Rig rig;
  setUp(() => rig = _Rig());
  tearDown(() => rig.backend.dispose());

  test("completing a goal uploads it without a delete", () async {
    rig.remote = [_task("grp_a")];
    rig.seedLocal([_task("grp_a")]);
    await rig.dataSource.getTasksForMutation();
    rig.requests.clear();

    await rig.save([
      _task("grp_a", done: ["2026-09-24"]),
    ]);

    expect(rig.requests, hasLength(1));
    expect(rig.writes("POST"), hasLength(1));
    expect(rig.writes("DELETE"), isEmpty);
  });

  test("deleting a goal deletes exactly that goal, by id", () async {
    rig.remote = [_task("a"), _task("b")];
    rig.seedLocal([_task("a"), _task("b")]);
    await rig.dataSource.getTasksForMutation();
    rig.requests.clear();

    await rig.save([_task("a")]);

    expect(rig.writes("DELETE").single, contains('id=in.("b")'));
  });

  test("never deletes a goal created on another device", () async {
    rig.remote = [_task("a")];
    rig.seedLocal([_task("a")]);
    await rig.dataSource.getTasksForMutation();
    // Another phone adds a goal after this one read the account.
    rig.remote = [_task("a"), _task("elsewhere")];
    rig.requests.clear();

    await rig.save([
      _task("a", done: ["2026-09-24"]),
    ]);

    expect(rig.writes("DELETE"), isEmpty);
  });

  test("a goal that was uploaded here can be deleted later", () async {
    rig.remote = [_task("a")];
    rig.seedLocal([_task("a")]);
    await rig.dataSource.getTasksForMutation();
    await rig.save([_task("a"), _task("fresh")]);
    rig.requests.clear();

    await rig.save([_task("a")]);

    expect(rig.writes("DELETE").single, contains('id=in.("fresh")'));
  });

  test("reading twice in quick succession asks the backend once", () async {
    rig.remote = [_task("a")];
    rig.seedLocal([_task("a")]);

    await rig.dataSource.getTasks();
    await rig.dataSource.getTasks();

    expect(rig.writes("GET"), hasLength(1));
  });
}
