import "dart:convert";

import "package:dartz/dartz.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

class ScheduleDataSource {
  ScheduleDataSource({
    required this._localStorageService,
    required this._supabaseService,
    required this._logger,
    required this._pendingSyncStore,
  });

  final AppLocalStorageService _localStorageService;
  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  final PendingSyncStore _pendingSyncStore;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its try/catch can mark the dataset pending for retry, instead
  // of hanging on the platform's own (much longer) socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

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
          .order("active_from")
          .order("weekday")
          .order("start_minutes")
          .timeout(_remoteCallTimeout);
      _logger.logResponse("select public.schedule_entries", rows);

      return rows
          .map((row) => _entryFromRow(row as Map<String, dynamic>))
          .toList();
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to fetch remote schedule_entries",
        error: error,
        stackTrace: stackTrace,
      );
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
            .upsert(rows, onConflict: "user_id,id")
            .timeout(_remoteCallTimeout);
      }

      final List<String> ids = entries.map((entry) => entry.id).toList();
      var delete = client
          .from("schedule_entries")
          .delete()
          .eq("user_id", userId);
      if (ids.isNotEmpty) {
        delete = delete.not("id", "in", "(${ids.join(",")})");
      }
      await delete.timeout(_remoteCallTimeout);
      await _pendingSyncStore.clear(PendingSyncDataset.schedule);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to sync remote schedule_entries",
        error: error,
        stackTrace: stackTrace,
      );
      await _pendingSyncStore.markPending(PendingSyncDataset.schedule);
      return;
    }
  }

  /// Re-attempts a previously failed remote sync using the current local
  /// state. No-op when nothing is pending for this dataset.
  Future<void> flushPendingSync() async {
    if (!_pendingSyncStore.contains(PendingSyncDataset.schedule)) {
      return;
    }
    final Either<AppError, List<ScheduleEntryEntity>> local =
        await getEntries();
    await local.fold((_) async {}, _syncRemoteEntries);
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
