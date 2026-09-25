import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";

/// Deletes the user's own data on an activity — time, pages and every session
/// logged for it — and keeps the activity itself, its settings and its notes.
///
/// For an activity handed out by a group the sessions are what its ranking is
/// computed from, so this also takes the user's share out of the group while
/// they stay in it.
class ClearSubjectDataUseCase {
  ClearSubjectDataUseCase({
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

  /// Returns the activity as it is once cleared.
  Future<Either<AppError, SubjectEntity>> call({
    required String subjectId,
  }) async {
    // The sessions go first: it is the step that can be refused, and nothing
    // else should change if it is.
    final AppError? entriesError =
        (await _activityRepository.clearSubjectEntries(
          subjectId,
        )).fold((error) => error, (_) => null);
    if (entriesError != null) {
      return Left(entriesError);
    }

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
                GenericAppError(
                  error: "Subject not found: $subjectId",
                  stackTrace: StackTrace.current,
                ),
              );
            }

            final SubjectEntity cleared = subjects[index].copyWith(
              totalSeconds: 0,
              currentPages: 0,
            );
            final Either<AppError, void> saveResult = await _subjectsRepository
                .saveSubjects([...subjects]..[index] = cleared);
            return saveResult.fold(Left.new, (_) => Right(cleared));
          });
        });
    if (subjectResult.isLeft()) {
      return subjectResult;
    }

    await _activityHistoryService.removeSubject(subjectId);
    final Map<String, DailyProgressEntity> removedByDay =
        await _subjectDailyHistoryService.removeSubject(subjectId);
    await _dailyProgressService.subtract(removedByDay);
    return subjectResult;
  }
}
