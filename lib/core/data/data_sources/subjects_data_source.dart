import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

/// The `user_subjects` table on the backend. Every call goes straight to
/// Supabase and throws whatever it fails with: the copy kept on the device,
/// merging what other phones did and retrying a failed upload belong to
/// `SubjectsRepository`.
class SubjectsDataSource {
  SubjectsDataSource({required this._supabaseService, required this._logger});

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its caller can mark the dataset pending for retry, instead of
  // hanging on the platform's own (much longer) socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  String? get currentUserId => _supabaseService.currentUserId;

  Future<List<SubjectEntity>> fetchSubjects(String userId) async {
    final List<dynamic> rows = await _supabaseService.requireClient
        .from("user_subjects")
        .select()
        .eq("user_id", userId)
        .order("created_at")
        .timeout(_remoteCallTimeout);
    _logger.logResponse("select public.user_subjects", rows);

    return rows
        .map((row) => _subjectFromRow(row as Map<String, dynamic>))
        .where(
          (subject) =>
              TimeCategoryType.tryByName(subject.category.name) != null,
        )
        .toList();
  }

  Future<void> upsertSubjects({
    required String userId,
    required List<SubjectEntity> subjects,
  }) async {
    if (subjects.isEmpty) {
      return;
    }
    await _supabaseService.requireClient
        .from("user_subjects")
        .upsert(
          subjects.map((subject) => _subjectToRow(subject, userId)).toList(),
          onConflict: "user_id,id",
        )
        .timeout(_remoteCallTimeout);
  }

  Future<void> deleteSubjects({
    required String userId,
    required List<String> ids,
  }) async {
    if (ids.isEmpty) {
      return;
    }
    await _supabaseService.requireClient
        .from("user_subjects")
        .delete()
        .eq("user_id", userId)
        .inFilter("id", ids)
        .timeout(_remoteCallTimeout);
  }

  SubjectEntity _subjectFromRow(Map<String, dynamic> row) =>
      SubjectEntity.fromMap({
        "id": row["id"],
        "name": row["name"],
        "category": row["category"],
        "colorValue": (row["color_value"] as num?)?.toInt() ?? 0,
        "totalSeconds": (row["total_seconds"] as num?)?.toInt() ?? 0,
        "goalSeconds": (row["goal_seconds"] as num?)?.toInt() ?? 0,
        "currentPages": (row["current_pages"] as num?)?.toInt() ?? 0,
        "goalPages": (row["goal_pages"] as num?)?.toInt() ?? 0,
        "notes": row["notes"],
        "iconName": row["icon_name"],
        "restMinutes": (row["rest_minutes"] as num?)?.toInt(),
        "focusSessionCount": (row["focus_session_count"] as num?)?.toInt(),
        "wallpaperIndex": (row["wallpaper_index"] as num?)?.toInt(),
        "activityType": row["activity_type"],
        "createdAt": row["created_at"],
        "groupId": row["group_id"],
        "groupActivityId": row["group_activity_id"],
      });

  Map<String, dynamic> _subjectToRow(SubjectEntity subject, String userId) {
    final Map<String, dynamic> row = {
      "id": subject.id,
      "user_id": userId,
      "name": subject.name,
      "category": subject.category.name,
      "color_value": subject.colorValue,
      "total_seconds": subject.totalSeconds,
      "goal_seconds": subject.goalSeconds,
      "current_pages": subject.currentPages,
      "goal_pages": subject.goalPages,
      "notes": subject.notes,
      "icon_name": subject.iconName,
      "rest_minutes": subject.restMinutes,
      "focus_session_count": subject.focusSessionCount,
      "wallpaper_index": subject.wallpaperIndex,
      "activity_type": subject.activityType.name,
      "group_id": subject.groupId,
      "group_activity_id": subject.groupActivityId,
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    };
    final DateTime? createdAt = subject.createdAt;
    if (createdAt != null) {
      row["created_at"] = createdAt.toUtc().toIso8601String();
    }
    return row;
  }
}
