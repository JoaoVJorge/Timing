import "dart:convert";
import "dart:math" as math;

import "package:get/get.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";

/// Tracks lightweight per-day activity counters (focus time, sessions, pages)
/// so the Home screen can show honest "today" metrics. Persists a date-keyed
/// map locally; only the current day is exposed reactively through [today].
class DailyProgressService {
  DailyProgressService({
    required this._localStorageService,
    AppLoggerService? logger,
  }) : _logger = logger ?? AppLoggerService();

  final AppLocalStorageService _localStorageService;
  final AppLoggerService _logger;

  final Map<String, DailyProgressEntity> _byDate = {};

  final Rx<DailyProgressEntity> today = const DailyProgressEntity().obs;

  /// Number of consecutive days, ending today (or yesterday, as a one-day
  /// grace period before the streak is considered broken), on which the user
  /// logged at least some focus time. Derived from [_byDate]; no extra storage.
  final RxInt currentStreak = 0.obs;

  List<DailyProgressEntity> get allProgress => _byDate.values.toList();

  bool get isEmpty => _byDate.isEmpty;

  static String dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, "0")}-"
      "${date.month.toString().padLeft(2, "0")}-"
      "${date.day.toString().padLeft(2, "0")}";

  Future<void> load() async {
    try {
      final String? saved = await _localStorageService.read<String?>(
        LocalStorageKeys.dailyProgress,
      );
      _byDate.clear();
      if (saved != null) {
        final Map<String, dynamic> decoded =
            jsonDecode(saved) as Map<String, dynamic>;
        _byDate.addAll(
          decoded.map(
            (key, value) => MapEntry(
              key,
              DailyProgressEntity.fromMap(value as Map<String, dynamic>),
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      _logger.logError(
        "DailyProgressService.load discarded a corrupt cache",
        error: error,
        stackTrace: stackTrace,
      );
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

  /// Brings each day up to what the backend recorded for it, from [entries]
  /// fetched off the backend.
  ///
  /// Another phone signed in to the same account only reaches this device
  /// through those entries, so a day is raised to the backend's total for it.
  /// It is never lowered: a session recorded here that has not uploaded yet
  /// keeps the local figure, and because the totals are compared rather than
  /// added, a session already synced is not counted twice. Session counts are
  /// not derivable from entries and stay local.
  Future<bool> reconcileWithActivityEntries(
    List<ActivityEntryEntity> entries,
  ) async {
    final Map<String, DailyProgressEntity> remoteByDay = {};
    for (final ActivityEntryEntity entry in entries) {
      final String key = dateKey(entry.timestamp);
      final DailyProgressEntity current =
          remoteByDay[key] ?? const DailyProgressEntity();
      remoteByDay[key] = current.copyWith(
        focusSeconds: current.focusSeconds + entry.seconds,
        pages: current.pages + entry.pages,
      );
    }
    bool changed = false;
    remoteByDay.forEach((key, remote) {
      final DailyProgressEntity local =
          _byDate[key] ?? const DailyProgressEntity();
      if (remote.focusSeconds <= local.focusSeconds &&
          remote.pages <= local.pages) {
        return;
      }
      _byDate[key] = local.copyWith(
        focusSeconds: math.max(local.focusSeconds, remote.focusSeconds),
        pages: math.max(local.pages, remote.pages),
      );
      changed = true;
    });
    if (!changed) {
      return false;
    }
    _refreshToday();
    await _persist();
    return true;
  }

  List<DailyProgressEntity> progressForLastDays(int days) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return List.generate(days, (index) {
      final DateTime date = today.subtract(Duration(days: days - index - 1));
      return _byDate[dateKey(date)] ?? const DailyProgressEntity();
    });
  }

  DailyProgressEntity _current() =>
      _byDate[dateKey(DateTime.now())] ?? const DailyProgressEntity();

  Future<void> _update(DailyProgressEntity updated) async {
    _byDate[dateKey(DateTime.now())] = updated;
    _refreshToday();
    await _persist();
  }

  void _refreshToday() {
    today.value = _current();
    _refreshStreak();
  }

  bool _hasFocus(DateTime date) =>
      (_byDate[dateKey(date)]?.focusSeconds ?? 0) > 0;

  void _refreshStreak() {
    final DateTime now = DateTime.now();
    DateTime cursor = DateTime(now.year, now.month, now.day);
    // Today counting as "not yet studied" doesn't break a streak from
    // yesterday, so start one day back when today has no focus time yet.
    if (!_hasFocus(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    int streak = 0;
    while (_hasFocus(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    currentStreak.value = streak;
  }

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
