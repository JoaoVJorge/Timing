import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/subjects_data_source.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class SubjectsRepository {
  SubjectsRepository({required this._subjectsDataSource});

  final SubjectsDataSource _subjectsDataSource;

  Future<Either<AppError, List<SubjectEntity>>> getSubjects() => _subjectsDataSource.getSubjects();

  Future<Either<AppError, void>> saveSubjects(List<SubjectEntity> subjects) =>
      _subjectsDataSource.saveSubjects(subjects);
}
