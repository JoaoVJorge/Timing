import "dart:convert";

import "package:get/get.dart";
import "package:help_out/core/domain/entities/daily_progress_entity.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";

/// Tracks lightweight per-day activity counters (focus time, sessions, pages)
/// so the Home screen can show honest "today" metrics. Persists a date-keyed
/// map locally; only the current day is exposed reactively through [today].
class DailyProgressService {
  DailyProgressService({required this._localStorageService});

  final AppLocalStorageService _localStorageService;

  final Map<String, DailyProgressEntity> _byDate = {};

  final Rx<DailyProgressEntity> today = const DailyProgressEntity().obs;

  static String dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, "0")}-"
      "${date.month.toString().padLeft(2, "0")}-"
      "${date.day.toString().padLeft(2, "0")}";

  Future<void> load() async {
    try {
      final String? saved = await _localStorageService.read<String?>(
        LocalStorageKeys.dailyProgress,
      );
      if (saved != null) {
        final Map<String, dynamic> decoded =
            jsonDecode(saved) as Map<String, dynamic>;
        _byDate
          ..clear()
          ..addAll(
            decoded.map(
              (key, value) => MapEntry(
                key,
                DailyProgressEntity.fromMap(value as Map<String, dynamic>),
              ),
            ),
          );
      }
    } catch (_) {
      _byDate.clear();
    }
    _refreshToday();
  }

  Future<void> addFocusSeconds(int seconds) async {
    if (seconds <= 0) {
      return;
    }
    final DailyProgressEntity current = _current();
    await _update(
      current.copyWith(focusSeconds: current.focusSeconds + seconds),
    );
  }

  Future<void> registerSession() async {
    final DailyProgressEntity current = _current();
    await _update(current.copyWith(sessions: current.sessions + 1));
  }

  Future<void> addPages(int pages) async {
    if (pages <= 0) {
      return;
    }
    final DailyProgressEntity current = _current();
    await _update(current.copyWith(pages: current.pages + pages));
  }

  DailyProgressEntity _current() =>
      _byDate[dateKey(DateTime.now())] ?? const DailyProgressEntity();

  Future<void> _update(DailyProgressEntity updated) async {
    _byDate[dateKey(DateTime.now())] = updated;
    _refreshToday();
    await _persist();
  }

  void _refreshToday() => today.value = _current();

  Future<void> _persist() async {
    final Map<String, dynamic> encoded = _byDate.map(
      (key, value) => MapEntry(key, value.toMap()),
    );
    await _localStorageService.write(
      LocalStorageKeys.dailyProgress,
      jsonEncode(encoded),
    );
  }
}
