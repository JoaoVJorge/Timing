import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";

class ActivityRepository {
  ActivityRepository({required this.activityDataSource});

  final ActivityDataSource activityDataSource;

  Future<Either<AppError, void>> logActivity({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) => activityDataSource.logActivity(
    category: category,
    subjectId: subjectId,
    subjectName: subjectName,
    seconds: seconds,
    pages: pages,
    completedTasks: completedTasks,
  );

  /// Deletes every session logged for the subject (see
  /// [ActivityDataSource.clearSubjectEntries]).
  Future<Either<AppError, void>> clearSubjectEntries(String subjectId) =>
      activityDataSource.clearSubjectEntries(subjectId);

  Future<Either<AppError, List<ActivityEntryEntity>>> getActivityEntries({
    int retentionDays = 400,
  }) => activityDataSource.getActivityEntries(retentionDays: retentionDays);
}
