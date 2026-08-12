import "package:dartz/dartz.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

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

  Future<Either<AppError, List<ActivityEntryEntity>>> getActivityEntries({
    int retentionDays = 400,
  }) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final DateTime cutoff = DateTime.now().toUtc().subtract(
        Duration(days: retentionDays),
      );
      final List<dynamic> rows = await _supabaseService.requireClient
          .from("activity_entries")
          .select()
          .eq("user_id", userId)
          .gte("occurred_at", cutoff.toIso8601String())
          .order("occurred_at");

      return Right(
        rows
            .map((row) => _entryFromRow(row as Map<String, dynamic>))
            .where(
              (entry) =>
                  entry.seconds > 0 ||
                  entry.pages > 0 ||
                  entry.completedTasks > 0,
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  ActivityEntryEntity _entryFromRow(Map<String, dynamic> row) =>
      ActivityEntryEntity(
        id: row["id"] as String,
        category:
            TimeCategoryType.tryByName(row["category"] as String? ?? "") ??
            TimeCategoryType.studying,
        subjectId: row["subject_id"] as String? ?? "",
        subjectName: row["subject_name"] as String? ?? "",
        timestamp: DateTime.parse(row["occurred_at"] as String).toLocal(),
        seconds: (row["seconds"] as num?)?.toInt() ?? 0,
        pages: (row["pages"] as num?)?.toInt() ?? 0,
        completedTasks: (row["completed_tasks"] as num?)?.toInt() ?? 0,
      );
}
