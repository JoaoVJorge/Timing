import "dart:async";

import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";

/// Adds time to an activity by hand, for work done without the timer running.
///
/// The time is recorded exactly as a timer session ending now would be: on the
/// activity's total, on today's counters and as a logged session, so goals,
/// history and group rankings all count it.
class AddSubjectTimeUseCase {
  AddSubjectTimeUseCase({
    required this._subjectsRepository,
    required this._activityRepository,
    required this._activityHistoryService,
    required this._subjectDailyHistoryService,
    required this._dailyProgressService,
    required this._activityChangeBus,
  });

  /// The most the backend accepts for one logged session.
  static const int maxSeconds = 24 * 60 * 60;

  final SubjectsRepository _subjectsRepository;
  final ActivityRepository _activityRepository;
  final ActivityHistoryService _activityHistoryService;
  final SubjectDailyHistoryService _subjectDailyHistoryService;
  final DailyProgressService _dailyProgressService;
  final ActivityChangeBus _activityChangeBus;

  /// Returns the activity with the time added.
  Future<Either<AppError, SubjectEntity>> call({
    required String subjectId,
    required int seconds,
  }) async {
    final int added = seconds.clamp(0, maxSeconds);
    final Either<AppError, SubjectEntity> subjectResult =
        await _subjectsRepository.runSerializedMutation(() async {
          final Either<AppError, List<SubjectEntity>> getResult =
              await _subjectsRepository.getSubjects();

          return getResult.fold((error) async => Left(error), (subjects) async {
            final int index = subjects.indexWhere(
              (subject) => subject.id == subjectId,
            );
            if (index == -1) {
              return Left(
                UnexpectedError(
                  cause: "Subject not found: $subjectId",
                  stackTrace: StackTrace.current,
                ),
              );
            }
            if (added == 0) {
              return Right(subjects[index]);
            }

            final SubjectEntity updated = subjects[index].copyWith(
              totalSeconds: subjects[index].totalSeconds + added,
            );
            final Either<AppError, void> saveResult = await _subjectsRepository
                .saveSubjects([...subjects]..[index] = updated);
            return saveResult.fold(Left.new, (_) => Right(updated));
          });
        });
    final SubjectEntity? subject = subjectResult.fold((_) => null, (s) => s);
    if (subject == null || added == 0) {
      return subjectResult;
    }

    await _activityHistoryService.record(
      category: subject.category,
      subjectId: subject.id,
      subjectName: subject.name,
      seconds: added,
    );
    // The upload can wait on a slow network; the numbers on this device do
    // not depend on it.
    unawaited(
      _activityRepository
          .logActivity(
            category: subject.category,
            subjectId: subject.id,
            subjectName: subject.name,
            seconds: added,
          )
          .then((_) => _activityChangeBus.notifyGroupActivityChanged()),
    );
    await _dailyProgressService.addFocusSeconds(added);
    await _subjectDailyHistoryService.addFocusSeconds(subject.id, added);
    return subjectResult;
  }
}
