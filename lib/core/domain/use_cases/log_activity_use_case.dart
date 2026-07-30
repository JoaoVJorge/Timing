import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/activity_repository.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class LogActivityUseCase {
  LogActivityUseCase({required this.activityRepository});

  final ActivityRepository activityRepository;

  Future<Either<AppError, void>> call({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) => activityRepository.logActivity(
    category: category,
    subjectId: subjectId,
    subjectName: subjectName,
    seconds: seconds,
    pages: pages,
    completedTasks: completedTasks,
  );
}
