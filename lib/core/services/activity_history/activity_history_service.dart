import "dart:collection";
import "dart:convert";
import "dart:math" as math;

import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/utils/id_generator.dart";

/// Append-only local trail of every logged activity, kept so the app can answer
/// time-and-category scoped questions ("studied yesterday", "pages read this
/// week") without a backend. The aggregated daily counters live in
/// [DailyProgressService]; this keeps the granular, per-session detail those
/// aggregates throw away (which category, which subject, when).
class ActivityHistoryService {
  ActivityHistoryService({
    required this._localStorageService,
    AppLoggerService? logger,
  }) : _logger = logger ?? AppLoggerService();

  final AppLocalStorageService _localStorageService;
  final AppLoggerService _logger;

  /// Entries older than this are pruned on write so the log stays bounded while
  /// still covering every period the UI can ask for (day / week / month).
  static const int retentionDays = 400;

  final List<ActivityEntryEntity> _entries = [];
  late final List<ActivityEntryEntity> _readOnlyEntries = UnmodifiableListView(
    _entries,
  );

  List<ActivityEntryEntity> get all => _readOnlyEntries;

  bool get isEmpty => _entries.isEmpty;

  Future<void> load() async {
    try {
      final String? saved = await _localStorageService.read<String?>(
        LocalStorageKeys.activityHistory,
      );
      _entries.clear();
      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
        _entries.addAll(
          decoded.map(
            (value) =>
                ActivityEntryEntity.fromMap(value as Map<String, dynamic>),
          ),
        );
      }
    } catch (error, stackTrace) {
      _logger.logError(
        "ActivityHistoryService.load discarded a corrupt cache",
        error: error,
        stackTrace: stackTrace,
      );
      _entries.clear();
    }
  }

  Future<void> record({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) async {
    if (seconds <= 0 && pages <= 0 && completedTasks <= 0) {
      return;
    }

    final DateTime now = DateTime.now();
    _entries.add(
      ActivityEntryEntity(
        id: "${now.microsecondsSinceEpoch}-${_entries.length}",
        category: category,
        subjectId: subjectId,
        subjectName: subjectName,
        timestamp: now,
        seconds: seconds,
        pages: pages,
        completedTasks: completedTasks,
      ),
    );
    _pruneOldEntries(now);
    await _persist();
  }

  /// Brings the per-subject, per-day totals up to what the backend recorded,
  /// so category and subject breakdowns cover work done on another phone.
  ///
  /// Entries carry different ids on each side (the local trail predates the
  /// backend's uuids), so they cannot be matched one to one. Totals per
  /// (day, subject) are compared instead and only the shortfall is added, as
  /// one synthetic entry. Nothing is ever removed or counted twice, and a
  /// second pass over the same data adds nothing.
  Future<bool> reconcileWithActivityEntries(
    List<ActivityEntryEntity> entries,
  ) async {
    final Map<String, List<ActivityEntryEntity>> remoteByKey = {};
    for (final ActivityEntryEntity entry in entries) {
      remoteByKey.putIfAbsent(_dayAndSubject(entry), () => []).add(entry);
    }
    final Map<String, _Totals> localByKey = {};
    for (final ActivityEntryEntity entry in _entries) {
      (localByKey[_dayAndSubject(entry)] ??= _Totals()).add(entry);
    }

    final List<ActivityEntryEntity> shortfalls = [];
    remoteByKey.forEach((key, group) {
      final _Totals remote = _Totals();
      for (final ActivityEntryEntity entry in group) {
        remote.add(entry);
      }
      final _Totals local = localByKey[key] ?? _Totals();
      final int seconds = math.max(0, remote.seconds - local.seconds);
      final int pages = math.max(0, remote.pages - local.pages);
      final int tasks = math.max(
        0,
        remote.completedTasks - local.completedTasks,
      );
      if (seconds == 0 && pages == 0 && tasks == 0) {
        return;
      }
      final ActivityEntryEntity latest = group.reduce(
        (a, b) => b.timestamp.isAfter(a.timestamp) ? b : a,
      );
      shortfalls.add(
        ActivityEntryEntity(
          id: "reconciled-${generateEntityId()}",
          category: latest.category,
          subjectId: latest.subjectId,
          subjectName: latest.subjectName,
          timestamp: latest.timestamp,
          seconds: seconds,
          pages: pages,
          completedTasks: tasks,
        ),
      );
    });
    if (shortfalls.isEmpty) {
      return false;
    }
    _entries.addAll(shortfalls);
    _pruneOldEntries(DateTime.now());
    _entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    await _persist();
    return true;
  }

  static String _dayAndSubject(ActivityEntryEntity entry) =>
      "${_startOfDay(entry.timestamp).toIso8601String()}|${entry.subjectId}";

  /// Forgets everything recorded for [subjectId]: the activity's "delete data".
  Future<void> removeSubject(String subjectId) async {
    final int before = _entries.length;
    _entries.removeWhere((entry) => entry.subjectId == subjectId);
    if (_entries.length != before) {
      await _persist();
    }
  }

  /// Entries whose timestamp falls in `[start, end)`, optionally filtered by
  /// [category] and/or [subjectId].
  List<ActivityEntryEntity> entriesBetween(
    DateTime start,
    DateTime end, {
    TimeCategoryType? category,
    String? subjectId,
  }) => _entries
      .where(
        (entry) =>
            !entry.timestamp.isBefore(start) &&
            entry.timestamp.isBefore(end) &&
            (category == null || entry.category == category) &&
            (subjectId == null || entry.subjectId == subjectId),
      )
      .toList();

  int secondsBetween(
    DateTime start,
    DateTime end, {
    TimeCategoryType? category,
    String? subjectId,
  }) => _sumBetween(
    start,
    end,
    category: category,
    subjectId: subjectId,
    valueOf: (entry) => entry.seconds,
  );

  int pagesBetween(
    DateTime start,
    DateTime end, {
    TimeCategoryType? category,
    String? subjectId,
  }) => _sumBetween(
    start,
    end,
    category: category,
    subjectId: subjectId,
    valueOf: (entry) => entry.pages,
  );

  int _sumBetween(
    DateTime start,
    DateTime end, {
    required int Function(ActivityEntryEntity entry) valueOf,
    TimeCategoryType? category,
    String? subjectId,
  }) {
    int total = 0;
    for (final ActivityEntryEntity entry in _entries) {
      if (entry.timestamp.isBefore(start) ||
          !entry.timestamp.isBefore(end) ||
          (category != null && entry.category != category) ||
          (subjectId != null && entry.subjectId != subjectId)) {
        continue;
      }
      total += valueOf(entry);
    }
    return total;
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _pruneOldEntries(DateTime now) {
    final DateTime cutoff = _startOfDay(
      now,
    ).subtract(const Duration(days: retentionDays));
    _entries.removeWhere((entry) => entry.timestamp.isBefore(cutoff));
  }

  Future<void> _persist() async {
    final List<Map<String, dynamic>> encoded = _entries
        .map((entry) => entry.toMap())
        .toList();
    await _localStorageService.write(
      LocalStorageKeys.activityHistory,
      jsonEncode(encoded),
    );
  }
}

class _Totals {
  int seconds = 0;
  int pages = 0;
  int completedTasks = 0;

  void add(ActivityEntryEntity entry) {
    seconds += entry.seconds;
    pages += entry.pages;
    completedTasks += entry.completedTasks;
  }
}
