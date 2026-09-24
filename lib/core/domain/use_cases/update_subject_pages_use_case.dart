import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class UpdateSubjectPagesUseCase {
  UpdateSubjectPagesUseCase({required this._subjectsRepository});

  final SubjectsRepository _subjectsRepository;

  /// Serialized with every other subject mutation: finishing a reading session
  /// saves the pages while the timer is still flushing its seconds, and two
  /// overlapping read-modify-write saves would drop one of the two changes.
  Future<Either<AppError, void>> call({
    required String subjectId,
    required int currentPages,
  }) => _subjectsRepository.runSerializedMutation(() async {
    final Either<AppError, List<SubjectEntity>> getResult =
        await _subjectsRepository.getSubjects();

    return getResult.fold((error) async => Left(error), (subjects) {
      final List<SubjectEntity> updatedSubjects = subjects
          .map(
            (subject) => subject.id == subjectId
                ? subject.copyWith(currentPages: currentPages)
                : subject,
          )
          .toList();

      return _subjectsRepository.saveSubjects(updatedSubjects);
    });
  });
}
