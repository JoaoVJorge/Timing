import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/activity_repository.dart";
import "package:help_out/core/domain/entities/activity_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GetActivityEntriesUseCase {
  GetActivityEntriesUseCase({required this.activityRepository});

  final ActivityRepository activityRepository;

  Future<Either<AppError, List<ActivityEntryEntity>>> call({
    int retentionDays = 400,
  }) => activityRepository.getActivityEntries(retentionDays: retentionDays);
}
