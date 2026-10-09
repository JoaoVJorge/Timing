import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

/// The `daily_goals` table on the backend. Every call goes straight to
/// Supabase and throws whatever it fails with: the copy kept on the device,
/// merging what other phones did and retrying a failed upload belong to
/// `DailyTasksRepository`.
class DailyTasksDataSource {
  DailyTasksDataSource({required this._supabaseService, required this._logger});

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its caller can mark the dataset pending for retry, instead of
  // hanging on the platform's own (much longer) socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  String? get currentUserId => _supabaseService.currentUserId;

  Future<List<DailyTaskEntity>> fetchTasks(String userId) async {
    final List<dynamic> rows = await _supabaseService.requireClient
        .from("daily_goals")
        .select()
        .eq("user_id", userId)
        .order("created_at")
        .timeout(_remoteCallTimeout);
    _logger.logResponse("select public.daily_goals", rows);

    return rows
        .map((row) => _taskFromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertTasks({
    required String userId,
    required List<DailyTaskEntity> tasks,
  }) async {
    if (tasks.isEmpty) {
      return;
    }
    await _supabaseService.requireClient
        .from("daily_goals")
        .upsert(
          tasks.map((task) => _taskToRow(task, userId)).toList(),
          onConflict: "user_id,id",
        )
        .timeout(_remoteCallTimeout);
  }

  Future<void> deleteTasks({
    required String userId,
    required List<String> ids,
  }) async {
    if (ids.isEmpty) {
      return;
    }
    await _supabaseService.requireClient
        .from("daily_goals")
        .delete()
        .eq("user_id", userId)
        .inFilter("id", ids)
        .timeout(_remoteCallTimeout);
  }

  DailyTaskEntity _taskFromRow(Map<String, dynamic> row) =>
      DailyTaskEntity.fromMap({
        "id": row["id"],
        "name": row["name"],
        "colorValue": (row["color_value"] as num?)?.toInt() ?? 0,
        "targetDays": (row["target_days"] as num?)?.toInt() ?? 0,
        "completedDates": row["completed_dates"] as List<dynamic>? ?? [],
        "sequenceType": row["sequence_type"] ?? row["goal_type"],
        "lastResolvedMissedDate": row["last_resolved_missed_date"],
        "goalType": row["goal_type"],
        "updatedAt": row["updated_at"],
        "groupId": row["group_id"],
        "groupActivityId": row["group_activity_id"],
        "reminderMinutes": row["reminder_minutes"],
      });

  Map<String, dynamic> _taskToRow(DailyTaskEntity task, String userId) => {
    "id": task.id,
    "user_id": userId,
    "name": task.name,
    "color_value": task.colorValue,
    "target_days": task.targetDays,
    "completed_dates": task.completedDates,
    "sequence_type": task.sequenceType.name,
    "last_resolved_missed_date": task.lastResolvedMissedDate,
    "goal_type": task.goalType.name,
    "group_id": task.groupId,
    "group_activity_id": task.groupActivityId,
    "reminder_minutes": task.reminderMinutes,
    "updated_at": (task.updatedAt ?? DateTime.now().toUtc())
        .toUtc()
        .toIso8601String(),
  };
}
