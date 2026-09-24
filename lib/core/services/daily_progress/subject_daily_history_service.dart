import "dart:convert";
import "dart:math" as math;

import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";

/// Per-subject version of [DailyProgressService]: keeps a day-by-day trail of
/// focus time and pages for each subject so the stats screen can draw an honest
/// "Comparativos" chart. Persisted as a nested `{subjectId: {date: counters}}`
/// map keyed the same way as the global daily progress.
class SubjectDailyHistoryService {
  SubjectDailyHistoryService({
    required this._localStorageService,
    AppLoggerService? logger,
  }) : _logger = logger ?? AppLoggerService();

  final AppLocalStorageService _localStorageService;
  final AppLoggerService _logger;

  final Map<String, Map<String, DailyProgressEntity>> _bySubject = {};

  bool get isEmpty => _bySubject.isEmpty;

  Future<void> load() async {
    try {
      final String? saved = await _localStorageService.read<String?>(
        LocalStorageKeys.subjectDailyHistory,
      );
      _bySubject.clear();
      if (saved != null) {
        final Map<String, dynamic> decoded =
            jsonDecode(saved) as Map<String, dynamic>;
        decoded.forEach((subjectId, days) {
          _bySubject[subjectId] = (days as Map<String, dynamic>).map(
            (date, value) => MapEntry(
              date,
              DailyProgressEntity.fromMap(value as Map<String, dynamic>),
            ),
          );
        });
      }
    } catch (error, stackTrace) {
      _logger.logError(
        "SubjectDailyHistoryService.load discarded a corrupt cache",
        error: error,
        stackTrace: stackTrace,
      );
      _bySubject.clear();
    }
  }

  Future<void> addFocusSeconds(String subjectId, int seconds) async {
    if (seconds <= 0) {
      return;
    }
    final DailyProgressEntity current = _current(subjectId);
    await _update(
      subjectId,
      current.copyWith(focusSeconds: current.focusSeconds + seconds),
    );
  }

  Future<void> addPages(String subjectId, int pages) async {
    if (pages <= 0) {
      return;
    }
    final DailyProgressEntity current = _current(subjectId);
    await _update(subjectId, current.copyWith(pages: current.pages + pages));
  }

  /// Per-subject version of [DailyProgressService.reconcileWithActivityEntries]:
  /// raises each (subject, day) to the backend's total, never lowering it.
  Future<bool> reconcileWithActivityEntries(
    List<ActivityEntryEntity> entries,
  ) async {
    final Map<String, Map<String, DailyProgressEntity>> remote = {};
    for (final ActivityEntryEntity entry in entries) {
      if (entry.subjectId.isEmpty) {
        continue;
      }
      final String key = DailyProgressService.dateKey(entry.timestamp);
      final Map<String, DailyProgressEntity> days = remote[entry.subjectId] ??=
          {};
      final DailyProgressEntity current =
          days[key] ?? const DailyProgressEntity();
      days[key] = current.copyWith(
        focusSeconds: current.focusSeconds + entry.seconds,
        pages: current.pages + entry.pages,
      );
    }
    bool changed = false;
    remote.forEach((subjectId, days) {
      days.forEach((key, remoteDay) {
        final DailyProgressEntity local =
            _bySubject[subjectId]?[key] ?? const DailyProgressEntity();
        if (remoteDay.focusSeconds <= local.focusSeconds &&
            remoteDay.pages <= local.pages) {
          return;
        }
        (_bySubject[subjectId] ??= {})[key] = local.copyWith(
          focusSeconds: math.max(local.focusSeconds, remoteDay.focusSeconds),
          pages: math.max(local.pages, remoteDay.pages),
        );
        changed = true;
      });
    });
    if (!changed) {
      return false;
    }
    await _persist();
    return true;
  }

  /// The subject's daily counters for the last [days] days, oldest first.
  List<DailyProgressEntity> historyForLastDays(String subjectId, int days) {
    final Map<String, DailyProgressEntity>? days$ = _bySubject[subjectId];
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return List.generate(days, (index) {
      final DateTime date = today.subtract(Duration(days: days - index - 1));
      return days$?[DailyProgressService.dateKey(date)] ??
          const DailyProgressEntity();
    });
  }

  DailyProgressEntity todayForSubject(String subjectId) => _current(subjectId);

  DailyProgressEntity _current(String subjectId) =>
      _bySubject[subjectId]?[DailyProgressService.dateKey(DateTime.now())] ??
      const DailyProgressEntity();

  Future<void> _update(String subjectId, DailyProgressEntity updated) async {
    (_bySubject[subjectId] ??= {})[DailyProgressService.dateKey(
          DateTime.now(),
        )] =
        updated;
    await _persist();
  }

  Future<void> _persist() async {
    final Map<String, dynamic> encoded = _bySubject.map(
      (subjectId, days) => MapEntry(
        subjectId,
        days.map((date, value) => MapEntry(date, value.toMap())),
      ),
    );
    await _localStorageService.write(
      LocalStorageKeys.subjectDailyHistory,
      jsonEncode(encoded),
    );
  }
}
