import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/subjects_repository.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class UpdateSubjectTimeUseCase {
  UpdateSubjectTimeUseCase({required this._subjectsRepository});

  final SubjectsRepository _subjectsRepository;

  Future<Either<AppError, void>> call({required String subjectId, required int totalSeconds}) async {
    final Either<AppError, List<SubjectEntity>> getResult = await _subjectsRepository.getSubjects();

    return getResult.fold((error) async => Left(error), (subjects) {
      final List<SubjectEntity> updatedSubjects = subjects
          .map((subject) => subject.id == subjectId ? subject.copyWith(totalSeconds: totalSeconds) : subject)
          .toList();

      return _subjectsRepository.saveSubjects(updatedSubjects);
    });
  }
}
