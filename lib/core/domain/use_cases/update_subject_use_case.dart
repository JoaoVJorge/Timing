import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/subjects_repository.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class UpdateSubjectUseCase {
  UpdateSubjectUseCase({required this.subjectsRepository});

  final SubjectsRepository subjectsRepository;

  Future<Either<AppError, SubjectEntity>> call({
    required String subjectId,
    required String name,
    required int colorValue,
    required int goalSeconds,
    required int goalPages,
    required String iconName,
    required int restMinutes,
    required int wallpaperIndex,
  }) async {
    final Either<AppError, List<SubjectEntity>> getResult =
        await subjectsRepository.getSubjects();

    return getResult.fold((error) async => Left(error), (subjects) async {
      SubjectEntity? updatedSubject;
      final List<SubjectEntity> updatedSubjects = subjects.map((subject) {
        if (subject.id != subjectId) {
          return subject;
        }

        updatedSubject = subject.copyWith(
          name: name,
          colorValue: colorValue,
          goalSeconds: goalSeconds,
          goalPages: goalPages,
          iconName: iconName,
          restMinutes: restMinutes,
          wallpaperIndex: wallpaperIndex,
        );
        return updatedSubject!;
      }).toList();

      if (updatedSubject == null) {
        return Left(
          GenericAppError(
            error: StateError("Subject not found"),
            stackTrace: StackTrace.current,
          ),
        );
      }

      final Either<AppError, void> saveResult = await subjectsRepository
          .saveSubjects(updatedSubjects);
      return saveResult.fold(Left.new, (_) => Right(updatedSubject!));
    });
  }
}
