import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class DeleteSubjectUseCase {
  DeleteSubjectUseCase({required this._subjectsRepository});

  final SubjectsRepository _subjectsRepository;

  Future<Either<AppError, void>> call({required String subjectId}) =>
      _subjectsRepository.runSerializedMutation(() async {
        final Either<AppError, List<SubjectEntity>> getResult =
            await _subjectsRepository.getSubjects();

        return getResult.fold(
          (error) async => Left(error),
          (subjects) => _subjectsRepository.saveSubjects(
            subjects.where((subject) => subject.id != subjectId).toList(),
          ),
        );
      });
}
