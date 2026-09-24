import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class PinSubjectToStartUseCase {
  PinSubjectToStartUseCase({required this.subjectsRepository});

  final SubjectsRepository subjectsRepository;

  Future<Either<AppError, void>> call({required String subjectId}) =>
      subjectsRepository.runSerializedMutation(() async {
        final Either<AppError, List<SubjectEntity>> getResult =
            await subjectsRepository.getSubjects();

        return getResult.fold((error) async => Left(error), (subjects) {
          final int index = subjects.indexWhere(
            (subject) => subject.id == subjectId,
          );
          if (index <= 0) {
            return subjectsRepository.saveSubjects(subjects);
          }

          final SubjectEntity subject = subjects[index];
          final List<SubjectEntity> reordered = [
            subject,
            for (int i = 0; i < subjects.length; i++)
              if (i != index) subjects[i],
          ];

          return subjectsRepository.saveSubjects(reordered);
        });
      });
}
