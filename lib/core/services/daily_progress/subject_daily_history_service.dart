import "dart:convert";

import "package:help_out/core/domain/entities/daily_progress_entity.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";

/// Per-subject version of [DailyProgressService]: keeps a day-by-day trail of
/// focus time and pages for each subject so the stats screen can draw an honest
/// "Comparativos" chart. Persisted as a nested `{subjectId: {date: counters}}`
/// map keyed the same way as the global daily progress.
class SubjectDailyHistoryService {
  SubjectDailyHistoryService({required this._localStorageService});

  final AppLocalStorageService _localStorageService;

  final Map<String, Map<String, DailyProgressEntity>> _bySubject = {};

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
    } catch (_) {
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

  DailyProgressEntity _current(String subjectId) =>
      _bySubject[subjectId]?[DailyProgressService.dateKey(DateTime.now())] ??
      const DailyProgressEntity();

  Future<void> _update(String subjectId, DailyProgressEntity updated) async {
    (_bySubject[subjectId] ??= {})[DailyProgressService.dateKey(
      DateTime.now(),
    )] = updated;
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
