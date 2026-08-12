import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class GetSubjectsUseCase {
  GetSubjectsUseCase({required this._subjectsRepository});

  final SubjectsRepository _subjectsRepository;

  Future<Either<AppError, List<SubjectEntity>>> call() =>
      _subjectsRepository.getSubjects();
}
