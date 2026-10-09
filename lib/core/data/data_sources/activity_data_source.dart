import "dart:async";

import "package:supabase_flutter/supabase_flutter.dart"
    show PostgrestException, PostgrestList;
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

/// The `activity_entries` log on the backend. Every call goes straight to
/// Supabase and throws whatever it fails with: queueing a failed upload for a
/// retry and reporting the failure belong to `ActivityRepository`.
class ActivityDataSource {
  ActivityDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its caller can queue the entry for retry, instead of hanging
  // on the platform's own (much longer) socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  String? get currentUserId => _supabaseService.currentUserId;

  /// Records one session. The row carries its own `id`, so sending it again
  /// after a lost answer does not duplicate it.
  Future<void> uploadEntry(Map<String, dynamic> row) => _supabaseService
      .requireClient
      .rpc(
        "record_activity_entry",
        params: {
          "entry_id": row["id"],
          "entry_category": row["category"],
          "entry_subject_id": row["subject_id"],
          "entry_subject_name": row["subject_name"],
          "entry_seconds": row["seconds"],
          "entry_pages": row["pages"],
          "entry_completed_tasks": row["completed_tasks"],
          "entry_occurred_at": row["occurred_at"],
        },
      )
      .timeout(_remoteCallTimeout);

  /// Deletes what [userId] logged for [subjectId] up to [until], so a session
  /// logged after the delete was asked for survives.
  Future<void> deleteSubjectEntries({
    required String userId,
    required String subjectId,
    required String until,
  }) => _supabaseService.requireClient
      .from("activity_entries")
      .delete()
      .eq("user_id", userId)
      .eq("subject_id", subjectId)
      .lte("occurred_at", until)
      .timeout(_remoteCallTimeout);

  /// Takes time back off the newest sessions of a subject. The removal carries
  /// its own `id`, so a request repeated after a lost answer is applied once.
  Future<void> removeSeconds(Map<String, dynamic> removal) => _supabaseService
      .requireClient
      .rpc(
        "remove_activity_seconds",
        params: {
          "removal_id": removal["id"],
          "entry_subject_id": removal["subject_id"],
          "seconds_to_remove": removal["seconds"],
          "removed_at": removal["removed_at"],
        },
      )
      .timeout(_remoteCallTimeout);

  /// The server caps a response at 1000 rows and the timer logs a row every
  /// autosave, so a few hours of focus already exceed one page. Reading only
  /// the first page (ordered oldest first) silently dropped the most recent
  /// days, so the history is read page by page until a short page.
  static const int _entriesPageSize = 1000;
  static const int _maxEntryPages = 60;
  static const String _missingFunctionCode = "PGRST202";

  /// Everything logged by [userId] in the last [retentionDays] days.
  Future<List<ActivityEntryEntity>> fetchEntries({
    required String userId,
    required int retentionDays,
  }) async {
    final String cutoff = DateTime.now()
        .toUtc()
        .subtract(Duration(days: retentionDays))
        .toIso8601String();
    try {
      return await _readEntryTotals(cutoff);
    } on PostgrestException catch (error) {
      // A backend that predates the totals function still has the rows.
      if (error.code != _missingFunctionCode) {
        rethrow;
      }
    }
    return _readEntryRows(userId, cutoff);
  }

  Future<List<ActivityEntryEntity>> _readEntryTotals(String cutoff) =>
      _readPages(
        (from, to) => _supabaseService.requireClient
            .rpc<PostgrestList>(
              "activity_entry_totals",
              params: {"period_start": cutoff},
            )
            .order("occurred_at")
            .order("category")
            .order("subject_id")
            .order("subject_name")
            .range(from, to),
        _entryFromTotalsRow,
      );

  Future<List<ActivityEntryEntity>> _readEntryRows(
    String userId,
    String cutoff,
  ) => _readPages(
    (from, to) => _supabaseService.requireClient
        .from("activity_entries")
        .select(
          "id, category, subject_id, subject_name, occurred_at, "
          "seconds, pages, completed_tasks",
        )
        .eq("user_id", userId)
        .gte("occurred_at", cutoff)
        // id breaks ties so rows sharing a timestamp are never skipped or
        // repeated across page boundaries.
        .order("occurred_at")
        .order("id")
        .range(from, to),
    _entryFromRow,
  );

  Future<List<ActivityEntryEntity>> _readPages(
    Future<PostgrestList> Function(int from, int to) readPage,
    ActivityEntryEntity Function(Map<String, dynamic> row) toEntry,
  ) async {
    final List<ActivityEntryEntity> entries = [];
    for (int page = 0; page < _maxEntryPages; page++) {
      final int from = page * _entriesPageSize;
      final PostgrestList rows = await readPage(
        from,
        from + _entriesPageSize - 1,
      ).timeout(_remoteCallTimeout);
      entries.addAll(
        rows
            .map(toEntry)
            .where(
              (entry) =>
                  entry.seconds > 0 ||
                  entry.pages > 0 ||
                  entry.completedTasks > 0,
            ),
      );
      if (rows.length < _entriesPageSize) {
        break;
      }
    }
    return entries;
  }

  ActivityEntryEntity _entryFromTotalsRow(Map<String, dynamic> row) =>
      _entryFromRow({
        ...row,
        "id":
            "${row["category"]}|${row["subject_id"] ?? ""}|"
            "${row["occurred_at"]}",
      });

  ActivityEntryEntity _entryFromRow(Map<String, dynamic> row) =>
      ActivityEntryEntity(
        id: row["id"] as String,
        category:
            TimeCategoryType.tryByName(row["category"] as String? ?? "") ??
            TimeCategoryType.studying,
        subjectId: row["subject_id"] as String? ?? "",
        subjectName: row["subject_name"] as String? ?? "",
        timestamp: DateTime.parse(row["occurred_at"] as String).toLocal(),
        seconds: (row["seconds"] as num?)?.toInt() ?? 0,
        pages: (row["pages"] as num?)?.toInt() ?? 0,
        completedTasks: (row["completed_tasks"] as num?)?.toInt() ?? 0,
      );
}
