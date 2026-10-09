import "dart:convert";

import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/sync_error_classifier.dart";

/// What one pass over queued actions got through: [processed] counts the
/// actions that left the queue (applied, or dropped because the server refused
/// them for good), [applied] only the ones that reached the backend.
typedef OfflineReplayResult = ({int processed, int applied});

/// Writes that could not reach the backend, kept on the device in the order
/// they were made so they can be replayed once the connection is back.
///
/// A queue belongs to one [PendingSyncDataset]: enqueueing marks it pending,
/// which is what tells the app there is something to flush. Several queues may
/// share a dataset, in which case their owner decides when the dataset is
/// clean again and uses [replay] directly instead of [flush].
class OfflineActionQueue {
  OfflineActionQueue({
    required this._localStorageService,
    required this._pendingSyncStore,
    required this._logger,
    required this._storageKey,
    required this._dataset,
    required this._label,
  });

  final AppLocalStorageService _localStorageService;
  final PendingSyncStore _pendingSyncStore;
  final AppLoggerService _logger;
  final LocalStorageKeys _storageKey;
  final String _dataset;

  /// Names a queued item in the log, e.g. `group action`.
  final String _label;

  Future<List<Map<String, dynamic>>> read() async {
    final String? saved = await _localStorageService.read<String?>(_storageKey);
    if (saved == null) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> write(List<Map<String, dynamic>> actions) =>
      _localStorageService.write(_storageKey, jsonEncode(actions));

  Future<void> enqueue(Map<String, dynamic> action) async {
    final List<Map<String, dynamic>> actions = await read();
    actions.add(action);
    await write(actions);
    await _pendingSyncStore.markPending(_dataset);
  }

  /// Applies [actions] oldest first and stops at the first one that fails for
  /// a reason that may pass (no network, a timeout), so a later action is
  /// never applied ahead of an earlier one.
  ///
  /// An action the server refuses for good is dropped and the pass goes on:
  /// retrying it could never succeed, and leaving it at the head would block
  /// everything queued behind it forever.
  Future<OfflineReplayResult> replay(
    List<Map<String, dynamic>> actions,
    Future<void> Function(Map<String, dynamic> action) apply,
  ) async {
    int processed = 0;
    int applied = 0;
    try {
      for (final Map<String, dynamic> action in actions) {
        try {
          await apply(action);
          applied++;
        } catch (error, stackTrace) {
          if (!isPermanentSyncFailure(error)) {
            rethrow;
          }
          _logger.logError(
            "Dropping a queued $_label the server rejected",
            error: error,
            stackTrace: stackTrace,
          );
        }
        processed++;
      }
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to flush a queued $_label",
        error: error,
        stackTrace: stackTrace,
      );
    }
    return (processed: processed, applied: applied);
  }

  /// Replays everything queued and keeps what could not be sent yet. Clears
  /// the dataset's pending mark once nothing is left. Returns how many actions
  /// left the queue; a no-op when the dataset is not pending.
  Future<int> flush(
    Future<void> Function(Map<String, dynamic> action) apply,
  ) async {
    if (!_pendingSyncStore.contains(_dataset)) {
      return 0;
    }
    final List<Map<String, dynamic>> actions = await read();
    if (actions.isEmpty) {
      await _pendingSyncStore.clear(_dataset);
      return 0;
    }

    final OfflineReplayResult result = await replay(actions, apply);
    final List<Map<String, dynamic>> remaining = actions.sublist(
      result.processed,
    );
    await write(remaining);
    if (remaining.isEmpty) {
      await _pendingSyncStore.clear(_dataset);
    }
    return result.processed;
  }
}
