import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/subjects_repository.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GetProfileStatsUseCase {
  GetProfileStatsUseCase({required this._subjectsRepository});

  final SubjectsRepository _subjectsRepository;

  Future<Either<AppError, ProfileStatsEntity>> call() async {
    final Either<AppError, List<SubjectEntity>> result = await _subjectsRepository.getSubjects();
    return result.map(ProfileStatsEntity.fromSubjects);
  }
}
