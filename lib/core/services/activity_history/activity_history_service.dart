import "dart:convert";

import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";

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

  List<ActivityEntryEntity> get all => List.unmodifiable(_entries);

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

  Future<void> replaceAll(List<ActivityEntryEntity> entries) async {
    final DateTime now = DateTime.now();
    _entries
      ..clear()
      ..addAll(entries);
    _pruneOldEntries(now);
    _entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    await _persist();
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
  }) => entriesBetween(
    start,
    end,
    category: category,
    subjectId: subjectId,
  ).fold(0, (total, entry) => total + entry.seconds);

  int pagesBetween(
    DateTime start,
    DateTime end, {
    TimeCategoryType? category,
    String? subjectId,
  }) => entriesBetween(
    start,
    end,
    category: category,
    subjectId: subjectId,
  ).fold(0, (total, entry) => total + entry.pages);

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
