import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/schedule_data_source.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/google_calendar/google_calendar_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

/// The weekly schedule. The copy on the device is what the app reads and
/// writes; the backend is brought in line after every save, and a save that
/// could not reach it marks the dataset pending so [flushPendingSync] sends
/// the current state later.
class ScheduleRepository {
  ScheduleRepository({
    required this._scheduleDataSource,
    required this._localStorageService,
    required this._logger,
    required this._pendingSyncStore,
    GoogleCalendarService? googleCalendarService,
  }) : _googleCalendar = googleCalendarService;

  final ScheduleDataSource _scheduleDataSource;
  final GoogleCalendarService? _googleCalendar;
  final AppLocalStorageService _localStorageService;
  final AppLoggerService _logger;
  final PendingSyncStore _pendingSyncStore;

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
      return Left(LocalDataError(cause: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveEntries(
    List<ScheduleEntryEntity> entries,
  ) async {
    try {
      await _saveLocalEntries(entries);
      await _syncRemoteEntries(entries);
      unawaited(_googleCalendar?.sync());
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(toAppError(error, stackTrace));
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

  Future<void> _saveLocalEntries(List<ScheduleEntryEntity> entries) async {
    final String encoded = jsonEncode(
      entries.map((entry) => entry.toMap()).toList(),
    );
    await _localStorageService.write(LocalStorageKeys.scheduleEntries, encoded);
  }

  /// What the backend holds, or nothing when signed out or unreachable: a
  /// device with no saved schedule then simply starts empty.
  Future<List<ScheduleEntryEntity>> _getRemoteEntries() async {
    final String? userId = _scheduleDataSource.currentUserId;
    if (userId == null) {
      return const [];
    }

    try {
      return await _scheduleDataSource.fetchEntries(userId);
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
    final String? userId = _scheduleDataSource.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      await _scheduleDataSource.replaceEntries(
        userId: userId,
        entries: entries,
      );
      await _pendingSyncStore.clear(PendingSyncDataset.schedule);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to sync remote schedule_entries",
        error: error,
        stackTrace: stackTrace,
      );
      await _pendingSyncStore.markPending(PendingSyncDataset.schedule);
    }
  }
}
