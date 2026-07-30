import "package:dartz/dartz.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";

class ActivityDataSource {
  ActivityDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Either<AppError, void>> logActivity({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null || seconds <= 0 && pages <= 0 && completedTasks <= 0) {
        return const Right(null);
      }

      await _supabaseService.requireClient.from("activity_entries").insert({
        "user_id": userId,
        "category": category.name,
        "subject_id": subjectId,
        "subject_name": subjectName,
        "seconds": seconds,
        "pages": pages,
        "completed_tasks": completedTasks,
      });
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }
}
