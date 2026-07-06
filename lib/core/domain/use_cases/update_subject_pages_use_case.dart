import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/subjects_repository.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class UpdateSubjectPagesUseCase {
  UpdateSubjectPagesUseCase({required this._subjectsRepository});

  final SubjectsRepository _subjectsRepository;

  Future<Either<AppError, void>> call({required String subjectId, required int currentPages}) async {
    final Either<AppError, List<SubjectEntity>> getResult = await _subjectsRepository.getSubjects();

    return getResult.fold((error) async => Left(error), (subjects) {
      final List<SubjectEntity> updatedSubjects = subjects
          .map((subject) => subject.id == subjectId ? subject.copyWith(currentPages: currentPages) : subject)
          .toList();

      return _subjectsRepository.saveSubjects(updatedSubjects);
    });
  }
}
