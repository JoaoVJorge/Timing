import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

/// Serves [total] entries the way PostgREST does: at most [maxRows] per
/// request, whatever range was asked for.
Future<http.Response> Function(http.Request) _serverWith(
  int total, {
  int maxRows = 1000,
  List<String>? log,
}) => (request) async {
  log?.add(request.url.query);
  final int offset =
      int.tryParse(request.url.queryParameters["offset"] ?? "") ?? 0;
  final int limit =
      int.tryParse(request.url.queryParameters["limit"] ?? "") ?? maxRows;
  final int end = (offset + (limit < maxRows ? limit : maxRows)).clamp(
    0,
    total,
  );
  return jsonResponse(request, [
    for (int i = offset; i < end; i++)
      {
        "id": "00000000-0000-4000-8000-${i.toString().padLeft(12, "0")}",
        "category": "studying",
        "subject_id": "s1",
        "subject_name": "Matemática",
        "occurred_at": DateTime.utc(
          2026,
          9,
          1,
        ).add(Duration(minutes: i)).toIso8601String(),
        "seconds": 10,
        "pages": 0,
        "completed_tasks": 0,
      },
  ]);
};

ActivityDataSource _dataSource(TestBackend backend) {
  final storage = MemoryStorage();
  return ActivityDataSource(
    supabaseService: TestSupabaseService(backend.client),
    localStorageService: storage,
    pendingSyncStore: PendingSyncStore(localStorageService: storage),
    logger: AppLoggerService(),
  );
}

void main() {
  test(
    "reads the whole history even when it exceeds the server's row cap",
    () async {
      final backend = TestBackend(_serverWith(2500));
      addTearDown(backend.dispose);

      final result = await _dataSource(backend).getActivityEntries();

      final entries = result.fold((_) => fail("expected Right"), (e) => e);
      expect(entries, hasLength(2500));
      // Every entry once, none skipped between pages.
      expect(entries.map((e) => e.id).toSet(), hasLength(2500));
    },
  );

  test("stops asking once a page comes back short", () async {
    final log = <String>[];
    final backend = TestBackend(_serverWith(1500, log: log));
    addTearDown(backend.dispose);

    await _dataSource(backend).getActivityEntries();

    expect(log, hasLength(2));
  });

  test("an empty history costs a single request", () async {
    final log = <String>[];
    final backend = TestBackend(_serverWith(0, log: log));
    addTearDown(backend.dispose);

    final result = await _dataSource(backend).getActivityEntries();

    expect(result.fold((_) => fail("expected Right"), (e) => e), isEmpty);
    expect(log, hasLength(1));
  });
}
