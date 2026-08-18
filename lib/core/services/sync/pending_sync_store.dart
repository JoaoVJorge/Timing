import "dart:convert";

import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";

/// Identifiers for the datasets that sync their full local state to the
/// backend and can therefore be retried as a unit.
class PendingSyncDataset {
  const PendingSyncDataset._();

  static const String subjects = "subjects";
  static const String schedule = "schedule";
  static const String dailyTasks = "dailyTasks";
}

/// Remembers which datasets have local changes that failed to reach the
/// backend, so they can be flushed on the next authenticated startup instead
/// of waiting for the user's next online edit. Persisted locally as a set of
/// [PendingSyncDataset] ids.
class PendingSyncStore {
  PendingSyncStore({required this._localStorageService});

  final AppLocalStorageService _localStorageService;

  final Set<String> _pending = {};

  Future<void> load() async {
    try {
      final String? saved = await _localStorageService.read<String?>(
        LocalStorageKeys.pendingRemoteSyncs,
      );
      _pending.clear();
      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
        _pending.addAll(decoded.map((value) => value as String));
      }
    } catch (_) {
      _pending.clear();
    }
  }

  bool contains(String dataset) => _pending.contains(dataset);

  Set<String> get all => Set.unmodifiable(_pending);

  Future<void> markPending(String dataset) async {
    if (_pending.add(dataset)) {
      await _persist();
    }
  }

  Future<void> clear(String dataset) async {
    if (_pending.remove(dataset)) {
      await _persist();
    }
  }

  Future<void> _persist() async {
    await _localStorageService.write(
      LocalStorageKeys.pendingRemoteSyncs,
      jsonEncode(_pending.toList()),
    );
  }
}
