import "dart:async";

import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/use_cases/log_activity_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";

/// Owns the "write the elapsed focus seconds everywhere" side of a timer
/// session: the backend update, the local activity trail, the daily counters
/// and the achievement check, plus the re-entrancy guard that coalesces
/// overlapping flushes and the auto-save throttle.
///
/// It is deliberately unaware of the timer's visual state — the controller
/// calls [flush] whenever progress must be durable (pause, background,
/// finish, dispose) and [autoSaveIfNeeded] on every tick.
class TimerSessionPersister {
  TimerSessionPersister({
    required this.autoSaveInterval,
    required this._updateSubjectTimeUseCase,
    required this._logActivityUseCase,
    required this._activityHistoryService,
    required this._dailyProgressService,
    required this._subjectDailyHistoryService,
    required this._achievementUnlockService,
    required this._subject,
    required this._sessionSeconds,
    required this._onGroupActivityChanged,
    DateTime? now,
  }) : _lastAutoSaveAt = now ?? DateTime.now();

  final UpdateSubjectTimeUseCase _updateSubjectTimeUseCase;
  final LogActivityUseCase _logActivityUseCase;
  final ActivityHistoryService _activityHistoryService;
  final DailyProgressService _dailyProgressService;
  final SubjectDailyHistoryService _subjectDailyHistoryService;
  final AchievementUnlockService _achievementUnlockService;
  final SubjectEntity Function() _subject;
  final int Function() _sessionSeconds;
  final void Function() _onGroupActivityChanged;
  final Duration autoSaveInterval;

  int _persistedSeconds = 0;
  bool _isPersisting = false;
  bool _shouldPersistAgain = false;
  bool _hasLoggedTime = false;
  DateTime _lastAutoSaveAt;

  /// Whether at least one flush has reached the backend. Used to decide if the
  /// session is worth recording as the user's "last activity".
  bool get hasLoggedTime => _hasLoggedTime;

  /// Seconds already written, so callers can tell whether there is anything new
  /// to save.
  int get persistedSeconds => _persistedSeconds;

  void flush() {
    if (_isPersisting) {
      _shouldPersistAgain = true;
      return;
    }
    _isPersisting = true;
    unawaited(_flushLoop());
  }

  void autoSaveIfNeeded(DateTime now) {
    if (_sessionSeconds() <= _persistedSeconds) {
      return;
    }
    if (now.difference(_lastAutoSaveAt) < autoSaveInterval) {
      return;
    }
    _lastAutoSaveAt = now;
    flush();
  }

  Future<void> _flushLoop() async {
    try {
      do {
        _shouldPersistAgain = false;
        await _flushOnce();
      } while (_shouldPersistAgain);
    } finally {
      _isPersisting = false;
    }
  }

  Future<void> _flushOnce() async {
    final SubjectEntity subject = _subject();
    final int sessionSecondsToPersist = _sessionSeconds();
    final int elapsedSinceLastPersist =
        sessionSecondsToPersist - _persistedSeconds;
    if (elapsedSinceLastPersist <= 0) {
      return;
    }

    final result = await _updateSubjectTimeUseCase(
      subjectId: subject.id,
      totalSeconds: subject.totalSeconds + sessionSecondsToPersist,
    );
    final bool didPersist = result.fold((_) => false, (_) => true);
    if (!didPersist) {
      return;
    }

    _hasLoggedTime = true;
    _persistedSeconds = sessionSecondsToPersist;
    unawaited(
      _activityHistoryService.record(
        category: subject.category,
        subjectId: subject.id,
        subjectName: subject.name,
        seconds: elapsedSinceLastPersist,
      ),
    );
    unawaited(
      _logActivityUseCase(
        category: subject.category,
        subjectId: subject.id,
        subjectName: subject.name,
        seconds: elapsedSinceLastPersist,
      ).then((_) => _onGroupActivityChanged()),
    );
    await _dailyProgressService.addFocusSeconds(elapsedSinceLastPersist);
    await _subjectDailyHistoryService.addFocusSeconds(
      subject.id,
      elapsedSinceLastPersist,
    );
    await _achievementUnlockService.checkForNewUnlocks();
    if (_sessionSeconds() > sessionSecondsToPersist) {
      _shouldPersistAgain = true;
    }
  }
}
