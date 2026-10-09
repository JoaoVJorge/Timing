import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";

/// Takes time back off an activity by hand, for a timer that was left running.
///
/// The time comes off the activity's total and off its most recent sessions,
/// newest first: today's counters go down before yesterday's, and the same is
/// asked of the backend so group rankings follow. An activity never goes
/// below zero.
class RemoveSubjectTimeUseCase {
  RemoveSubjectTimeUseCase({
    required this._subjectsRepository,
    required this._activityRepository,
    required this._activityHistoryService,
    required this._subjectDailyHistoryService,
    required this._dailyProgressService,
  });

  final SubjectsRepository _subjectsRepository;
  final ActivityRepository _activityRepository;
  final ActivityHistoryService _activityHistoryService;
  final SubjectDailyHistoryService _subjectDailyHistoryService;
  final DailyProgressService _dailyProgressService;

  /// Returns the activity with the time removed.
  Future<Either<AppError, SubjectEntity>> call({
    required String subjectId,
    required int seconds,
  }) async {
    int removed = 0;
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
            final SubjectEntity current = subjects[index];
            final int removable = seconds.clamp(0, current.totalSeconds);
            if (removable == 0) {
              return Right(current);
            }

            // The backend request goes first: it is the step that can be
            // refused, and nothing else should change if it is.
            final AppError? removalError =
                (await _activityRepository.removeSubjectSeconds(
                  subjectId: subjectId,
                  seconds: removable,
                )).fold((error) => error, (_) => null);
            if (removalError != null) {
              return Left(removalError);
            }

            final SubjectEntity updated = current.copyWith(
              totalSeconds: current.totalSeconds - removable,
            );
            final Either<AppError, void> saveResult = await _subjectsRepository
                .saveSubjects([...subjects]..[index] = updated);
            return saveResult.fold(Left.new, (_) {
              removed = removable;
              return Right(updated);
            });
          });
        });
    if (removed == 0) {
      return subjectResult;
    }

    await _activityHistoryService.removeSeconds(subjectId, removed);
    final Map<String, DailyProgressEntity> removedByDay =
        await _subjectDailyHistoryService.removeFocusSeconds(
          subjectId,
          removed,
        );
    await _dailyProgressService.subtract(removedByDay);
    return subjectResult;
  }
}
