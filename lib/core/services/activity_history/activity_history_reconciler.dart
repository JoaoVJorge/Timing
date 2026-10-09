import "package:dartz/dartz.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";

/// Keeps this device's progress caches in step with the account's
/// `activity_entries`, which is how work done on another phone reaches it.
///
/// The caches ([DailyProgressService], [SubjectDailyHistoryService],
/// [ActivityHistoryService]) are written locally as sessions happen, so two
/// phones on one account only agree through the backend. A single backfill
/// left a phone stuck with whatever the backend held when it ran (for one
/// phone, two days); the reconcile therefore runs again over time:
///
///  * the first pass reads the whole retention window;
///  * later passes read [recentWindowDays], at most once per [minInterval]
///    unless forced, which catches sessions the other phone uploaded late
///    without re-reading the full history each time;
///  * every pass in between reads only [latestWindowDays], a small read, so
///    what the other phone logged today shows up the next time this one is
///    opened rather than hours later.
class ActivityHistoryReconciler {
  ActivityHistoryReconciler({
    required this.fetchEntries,
    required this.activityHistory,
    required this.dailyProgress,
    required this.subjectHistory,
    required this.localStorage,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Future<Either<AppError, List<ActivityEntryEntity>>> Function({
    required int retentionDays,
  })
  fetchEntries;
  final ActivityHistoryService activityHistory;
  final DailyProgressService dailyProgress;
  final SubjectDailyHistoryService subjectHistory;
  final AppLocalStorageService localStorage;
  final DateTime Function() _now;

  static const Duration minInterval = Duration(hours: 6);
  static const int recentWindowDays = 60;
  static const int latestWindowDays = 2;

  /// Returns whether any cache changed. A failed read changes nothing and does
  /// not count as a pass, so it is retried on the next trigger.
  Future<bool> reconcile({bool force = false}) async {
    final DateTime? last = await _lastReconciledAt();
    final DateTime now = _now();
    final bool isLatestOnly =
        !force && last != null && now.difference(last) < minInterval;

    final Either<AppError, List<ActivityEntryEntity>> result =
        await fetchEntries(
          retentionDays: last == null
              ? ActivityHistoryService.retentionDays
              : isLatestOnly
              ? latestWindowDays
              : recentWindowDays,
        );
    final List<ActivityEntryEntity>? entries = result.fold(
      (_) => null,
      (value) => value,
    );
    if (entries == null) {
      return false;
    }

    bool changed = false;
    if (entries.isNotEmpty) {
      final List<bool> results = await Future.wait([
        activityHistory.reconcileWithActivityEntries(entries),
        dailyProgress.reconcileWithActivityEntries(entries),
        subjectHistory.reconcileWithActivityEntries(entries),
      ]);
      changed = results.any((didChange) => didChange);
    }
    if (!isLatestOnly) {
      await localStorage.write(
        LocalStorageKeys.activityHistoryReconciledAt,
        now.toUtc().toIso8601String(),
      );
    }
    return changed;
  }

  Future<DateTime?> _lastReconciledAt() async {
    final String? raw = await localStorage.read<String?>(
      LocalStorageKeys.activityHistoryReconciledAt,
    );
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
