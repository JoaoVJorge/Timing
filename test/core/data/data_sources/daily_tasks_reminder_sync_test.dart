import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

DailyTaskEntity _goal({int? reminder}) => DailyTaskEntity(
  id: "a",
  name: "Beber água",
  colorValue: 1,
  targetDays: 0,
  completedDates: const [],
  reminderMinutes: reminder,
);

void main() {
  late MemoryStorage storage;
  late TestBackend backend;
  late DailyTasksDataSource dataSource;
  late List<Map<String, dynamic>> remoteRows;
  late List<dynamic> uploadedRows;

  setUp(() {
    storage = MemoryStorage();
    remoteRows = [];
    uploadedRows = [];
    backend = TestBackend((request) async {
      if (request.method == "GET") {
        return jsonResponse(request, remoteRows);
      }
      if (request.method == "POST") {
        uploadedRows = jsonDecode(request.body) as List<dynamic>;
      }
      return http.Response("", 201, request: request);
    });
    dataSource = DailyTasksDataSource(
      localStorageService: storage,
      supabaseService: TestSupabaseService(backend.client),
      logger: AppLoggerService(),
      pendingSyncStore: PendingSyncStore(localStorageService: storage),
    );
  });

  tearDown(() => backend.dispose());

  test("uploads the reminder time with the goal", () async {
    await dataSource.saveTasks([_goal(reminder: 12 * 60)]);
    await pumpEventQueue();

    expect((uploadedRows.single as Map)["reminder_minutes"], 12 * 60);
  });

  test(
    "uploads a removed reminder as null, so it is cleared remotely",
    () async {
      await dataSource.saveTasks([_goal()]);
      await pumpEventQueue();

      final Map<dynamic, dynamic> row = uploadedRows.single as Map;
      expect(row.containsKey("reminder_minutes"), true);
      expect(row["reminder_minutes"], isNull);
    },
  );

  test("reads the reminder time back from the account", () async {
    remoteRows = [
      {
        "id": "a",
        "user_id": "user-1",
        "name": "Beber água",
        "color_value": 1,
        "target_days": 0,
        "completed_dates": <String>[],
        "goal_type": "total",
        "sequence_type": "casual",
        "reminder_minutes": 450,
        "updated_at": "2026-10-07T00:00:00Z",
      },
    ];

    final tasks = (await dataSource.getTasks()).getOrElse(() => []);

    expect(tasks.single.reminderMinutes, 450);
  });

  test("announces the goals it saves and the ones it merges in", () async {
    final List<List<DailyTaskEntity>> announced = [];
    final subscription = dataSource.onLocalTasksChanged.listen(announced.add);
    addTearDown(subscription.cancel);
    // A full read of the account first, so the upload below counts as synced.
    await dataSource.getTasksForMutation();

    await dataSource.saveTasks([_goal(reminder: 60)]);
    await pumpEventQueue();
    expect(announced.last.single.reminderMinutes, 60);

    remoteRows = [
      {
        "id": "b",
        "user_id": "user-1",
        "name": "Ler",
        "color_value": 1,
        "target_days": 0,
        "completed_dates": <String>[],
        "goal_type": "total",
        "sequence_type": "casual",
        "reminder_minutes": 90,
        "updated_at": "2026-10-07T00:00:00Z",
      },
    ];
    await dataSource.refreshAfterGroupLinkChange();
    await pumpEventQueue();

    expect(announced.last.map((task) => task.id), containsAll(["a", "b"]));
  });
}
