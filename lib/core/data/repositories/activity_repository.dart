import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/activity_data_source.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";

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
}
