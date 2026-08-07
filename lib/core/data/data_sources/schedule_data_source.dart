import "dart:convert";

import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";

class ScheduleDataSource {
  ScheduleDataSource({
    required this._localStorageService,
    required this._supabaseService,
  });

  final AppLocalStorageService _localStorageService;
  final SupabaseService _supabaseService;

  Future<Either<AppError, List<ScheduleEntryEntity>>> getEntries() async {
    try {
      final String? saved = await _localStorageService.read<String?>(
        LocalStorageKeys.scheduleEntries,
      );

      if (saved == null) {
        final List<ScheduleEntryEntity> remoteEntries =
            await _getRemoteEntries();
        if (remoteEntries.isNotEmpty) {
          await _saveLocalEntries(remoteEntries);
        }
        return Right(remoteEntries);
      }

      final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
      return Right(
        decoded
            .map(
              (item) =>
                  ScheduleEntryEntity.fromMap(item as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveEntries(
    List<ScheduleEntryEntity> entries,
  ) async {
    try {
      final String encoded = jsonEncode(
        entries.map((entry) => entry.toMap()).toList(),
      );
      await _localStorageService.write(
        LocalStorageKeys.scheduleEntries,
        encoded,
      );
      await _syncRemoteEntries(entries);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<void> _saveLocalEntries(List<ScheduleEntryEntity> entries) async {
    final String encoded = jsonEncode(
      entries.map((entry) => entry.toMap()).toList(),
    );
    await _localStorageService.write(LocalStorageKeys.scheduleEntries, encoded);
  }

  Future<List<ScheduleEntryEntity>> _getRemoteEntries() async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return const [];
    }

    try {
      final List<dynamic> rows = await _supabaseService.requireClient
          .from("schedule_entries")
          .select()
          .eq("user_id", userId)
          .order("weekday")
          .order("start_minutes");

      return rows
          .map((row) => _entryFromRow(row as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _syncRemoteEntries(List<ScheduleEntryEntity> entries) async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final client = _supabaseService.requireClient;
      final List<Map<String, dynamic>> rows = entries
          .map((entry) => _entryToRow(entry, userId))
          .toList();

      if (rows.isNotEmpty) {
        await client
            .from("schedule_entries")
            .upsert(rows, onConflict: "user_id,id");
      }

      final List<String> ids = entries.map((entry) => entry.id).toList();
      var delete = client
          .from("schedule_entries")
          .delete()
          .eq("user_id", userId);
      if (ids.isNotEmpty) {
        delete = delete.not("id", "in", "(${ids.join(",")})");
      }
      await delete;
    } catch (_) {
      return;
    }
  }

  ScheduleEntryEntity _entryFromRow(Map<String, dynamic> row) =>
      ScheduleEntryEntity.fromMap({
        "id": row["id"],
        "title": row["title"],
        "weekday": (row["weekday"] as num?)?.toInt() ?? DateTime.monday,
        "startMinutes": (row["start_minutes"] as num?)?.toInt(),
        "endMinutes": (row["end_minutes"] as num?)?.toInt(),
        "colorValue": (row["color_value"] as num?)?.toInt() ?? 0,
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
        "updated_at": DateTime.now().toUtc().toIso8601String(),
      };
}
