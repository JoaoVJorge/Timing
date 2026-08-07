import "dart:convert";

import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";

class DailyTasksDataSource {
  DailyTasksDataSource({
    required this._localStorageService,
    required this._supabaseService,
  });

  final AppLocalStorageService _localStorageService;
  final SupabaseService _supabaseService;

  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() async {
    try {
      final String? savedTasks = await _localStorageService.read<String?>(
        LocalStorageKeys.dailyTasks,
      );

      if (savedTasks == null) {
        final List<DailyTaskEntity> remoteTasks = await _getRemoteTasks();
        if (remoteTasks.isNotEmpty) {
          await _saveLocalTasks(remoteTasks);
        }
        return Right(remoteTasks);
      }

      final List<dynamic> decoded = jsonDecode(savedTasks) as List<dynamic>;
      return Right(
        decoded
            .map(
              (item) => DailyTaskEntity.fromMap(item as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveTasks(List<DailyTaskEntity> tasks) async {
    try {
      final String encoded = jsonEncode(
        tasks.map((task) => task.toMap()).toList(),
      );
      await _localStorageService.write(LocalStorageKeys.dailyTasks, encoded);
      await _syncRemoteTasks(tasks);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<void> _saveLocalTasks(List<DailyTaskEntity> tasks) async {
    final String encoded = jsonEncode(
      tasks.map((task) => task.toMap()).toList(),
    );
    await _localStorageService.write(LocalStorageKeys.dailyTasks, encoded);
  }

  Future<List<DailyTaskEntity>> _getRemoteTasks() async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return const [];
    }

    try {
      final List<dynamic> rows = await _supabaseService.requireClient
          .from("daily_goals")
          .select()
          .eq("user_id", userId)
          .order("created_at");

      return rows
          .map((row) => _taskFromRow(row as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _syncRemoteTasks(List<DailyTaskEntity> tasks) async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final client = _supabaseService.requireClient;
      final List<Map<String, dynamic>> rows = tasks
          .map((task) => _taskToRow(task, userId))
          .toList();

      if (rows.isNotEmpty) {
        await client.from("daily_goals").upsert(rows, onConflict: "user_id,id");
      }

      final List<String> ids = tasks.map((task) => task.id).toList();
      var delete = client.from("daily_goals").delete().eq("user_id", userId);
      if (ids.isNotEmpty) {
        delete = delete.not("id", "in", "(${ids.join(",")})");
      }
      await delete;
    } catch (_) {
      return;
    }
  }

  DailyTaskEntity _taskFromRow(Map<String, dynamic> row) =>
      DailyTaskEntity.fromMap({
        "id": row["id"],
        "name": row["name"],
        "colorValue": (row["color_value"] as num?)?.toInt() ?? 0,
        "targetDays": (row["target_days"] as num?)?.toInt() ?? 0,
        "completedDates": row["completed_dates"] as List<dynamic>? ?? [],
        "goalType": row["goal_type"],
      });

  Map<String, dynamic> _taskToRow(DailyTaskEntity task, String userId) => {
    "id": task.id,
    "user_id": userId,
    "name": task.name,
    "color_value": task.colorValue,
    "target_days": task.targetDays,
    "completed_dates": task.completedDates,
    "goal_type": task.goalType.name,
    "updated_at": DateTime.now().toUtc().toIso8601String(),
  };
}
