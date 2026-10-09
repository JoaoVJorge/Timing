import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

/// The `schedule_entries` table on the backend. Every call goes straight to
/// Supabase and throws whatever it fails with: the copy kept on the device and
/// retrying a failed upload belong to `ScheduleRepository`.
class ScheduleDataSource {
  ScheduleDataSource({required this._supabaseService, required this._logger});

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its caller can mark the dataset pending for retry, instead of
  // hanging on the platform's own (much longer) socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  String? get currentUserId => _supabaseService.currentUserId;

  Future<List<ScheduleEntryEntity>> fetchEntries(String userId) async {
    final List<dynamic> rows = await _supabaseService.requireClient
        .from("schedule_entries")
        .select()
        .eq("user_id", userId)
        .order("active_from")
        .order("weekday")
        .order("start_minutes")
        .timeout(_remoteCallTimeout);
    _logger.logResponse("select public.schedule_entries", rows);

    return rows
        .map((row) => _entryFromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// Makes the backend hold exactly [entries] for [userId]: uploads them and
  /// deletes every other entry of that user.
  Future<void> replaceEntries({
    required String userId,
    required List<ScheduleEntryEntity> entries,
  }) async {
    final client = _supabaseService.requireClient;
    final List<Map<String, dynamic>> rows = entries
        .map((entry) => _entryToRow(entry, userId))
        .toList();

    if (rows.isNotEmpty) {
      await client
          .from("schedule_entries")
          .upsert(rows, onConflict: "user_id,id")
          .timeout(_remoteCallTimeout);
    }

    final List<String> ids = entries.map((entry) => entry.id).toList();
    var delete = client.from("schedule_entries").delete().eq("user_id", userId);
    if (ids.isNotEmpty) {
      delete = delete.not("id", "in", "(${ids.join(",")})");
    }
    await delete.timeout(_remoteCallTimeout);
  }

  ScheduleEntryEntity _entryFromRow(Map<String, dynamic> row) =>
      ScheduleEntryEntity.fromMap({
        "id": row["id"],
        "title": row["title"],
        "weekday": (row["weekday"] as num?)?.toInt() ?? DateTime.monday,
        "startMinutes": (row["start_minutes"] as num?)?.toInt(),
        "endMinutes": (row["end_minutes"] as num?)?.toInt(),
        "colorValue": (row["color_value"] as num?)?.toInt() ?? 0,
        "activeFrom": row["active_from"],
        "activeUntil": row["active_until"],
      });

  Map<String, dynamic> _entryToRow(ScheduleEntryEntity entry, String userId) =>
      {
        "id": entry.id,
        "user_id": userId,
        "title": entry.title,
        "weekday": entry.weekday,
        "start_minutes": entry.startMinutes,
        "end_minutes": entry.endMinutes,
        "color_value": entry.colorValue,
        "active_from": _dateOnly(entry.activeFrom),
        "active_until": entry.activeUntil == null
            ? null
            : _dateOnly(entry.activeUntil!),
        "updated_at": DateTime.now().toUtc().toIso8601String(),
      };

  String _dateOnly(DateTime value) =>
      "${value.year.toString().padLeft(4, "0")}-"
      "${value.month.toString().padLeft(2, "0")}-"
      "${value.day.toString().padLeft(2, "0")}";
}
