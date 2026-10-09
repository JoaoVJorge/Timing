import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

const String _totalsPath = "/rest/v1/rpc/activity_entry_totals";
const String _rowsPath = "/rest/v1/activity_entries";

/// Serves [total] entries the way PostgREST does: at most [maxRows] per
/// request, whatever range was asked for.
Future<http.Response> Function(http.Request) _serverWith(
  int total, {
  int maxRows = 1000,
  bool totalsDeployed = true,
  List<http.Request>? log,
}) => (request) async {
  log?.add(request);
  final bool isTotals = request.url.path == _totalsPath;
  if (isTotals && !totalsDeployed) {
    return jsonResponse(request, {
      "code": "PGRST202",
      "details": null,
      "hint": null,
      "message":
          "Could not find the function public.activity_entry_totals"
          "(period_start) in the schema cache",
    }, 404);
  }
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
        if (!isTotals)
          "id": "00000000-0000-4000-8000-${i.toString().padLeft(12, "0")}",
        "category": "studying",
        "subject_id": "s1",
        "subject_name": "Matemática",
        "occurred_at": DateTime.utc(
          2026,
          9,
          1,
        ).add(Duration(minutes: 15 * i)).toIso8601String(),
        "seconds": isTotals ? 900 : 10,
        "pages": 0,
        "completed_tasks": 0,
      },
  ]);
};

Iterable<http.Request> _to(List<http.Request> log, String path) =>
    log.where((request) => request.url.path == path);

ActivityRepository _dataSource(TestBackend backend) {
  final storage = MemoryStorage();
  return ActivityRepository(
    activityDataSource: ActivityDataSource(
      supabaseService: TestSupabaseService(backend.client),
    ),
    localStorageService: storage,
    pendingSyncStore: PendingSyncStore(localStorageService: storage),
    logger: AppLoggerService(),
  );
}

void main() {
  test("reads the history as per-slot totals in a single request", () async {
    final log = <http.Request>[];
    final backend = TestBackend(_serverWith(300, log: log));
    addTearDown(backend.dispose);

    final result = await _dataSource(backend).getActivityEntries();

    final entries = result.fold((_) => fail("expected Right"), (e) => e);
    expect(entries, hasLength(300));
    expect(entries.first.seconds, 900);
    expect(entries.first.subjectId, "s1");
    expect(entries.first.timestamp, DateTime.utc(2026, 9, 1).toLocal());
    expect(log, hasLength(1));
    expect(log.single.url.path, _totalsPath);
    expect(
      jsonDecode(log.single.body) as Map<String, dynamic>,
      contains("period_start"),
    );
  });

  test(
    "pages through the totals when they exceed the server's row cap",
    () async {
      final log = <http.Request>[];
      final backend = TestBackend(_serverWith(2500, log: log));
      addTearDown(backend.dispose);

      final result = await _dataSource(backend).getActivityEntries();

      final entries = result.fold((_) => fail("expected Right"), (e) => e);
      expect(entries, hasLength(2500));
      expect(entries.map((e) => e.id).toSet(), hasLength(2500));
      expect(_to(log, _totalsPath), hasLength(3));
      expect(_to(log, _rowsPath), isEmpty);
    },
  );

  test(
    "reads every row when the totals function is not deployed yet",
    () async {
      final log = <http.Request>[];
      final backend = TestBackend(
        _serverWith(2500, totalsDeployed: false, log: log),
      );
      addTearDown(backend.dispose);

      final result = await _dataSource(backend).getActivityEntries();

      final entries = result.fold((_) => fail("expected Right"), (e) => e);
      expect(entries, hasLength(2500));
      // Every entry once, none skipped between pages.
      expect(entries.map((e) => e.id).toSet(), hasLength(2500));
      expect(_to(log, _totalsPath), hasLength(1));
      expect(_to(log, _rowsPath), hasLength(3));
    },
  );

  test("stops asking once a page comes back short", () async {
    final log = <http.Request>[];
    final backend = TestBackend(
      _serverWith(1500, totalsDeployed: false, log: log),
    );
    addTearDown(backend.dispose);

    await _dataSource(backend).getActivityEntries();

    expect(_to(log, _rowsPath), hasLength(2));
  });

  test("an empty history costs a single request", () async {
    final log = <http.Request>[];
    final backend = TestBackend(_serverWith(0, log: log));
    addTearDown(backend.dispose);

    final result = await _dataSource(backend).getActivityEntries();

    expect(result.fold((_) => fail("expected Right"), (e) => e), isEmpty);
    expect(log, hasLength(1));
  });

  test(
    "a failing totals read is reported instead of reading every row",
    () async {
      final log = <http.Request>[];
      final backend = TestBackend((request) async {
        log.add(request);
        return jsonResponse(request, {
          "code": "57014",
          "details": null,
          "hint": null,
          "message": "canceling statement due to statement timeout",
        }, 500);
      });
      addTearDown(backend.dispose);

      final result = await _dataSource(backend).getActivityEntries();

      expect(result.isLeft(), isTrue);
      expect(_to(log, _rowsPath), isEmpty);
    },
  );
}
