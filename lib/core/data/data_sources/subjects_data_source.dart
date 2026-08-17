import "dart:convert";

import "package:dartz/dartz.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

class SubjectsDataSource {
  SubjectsDataSource({
    required this._localStorageService,
    required this._supabaseService,
    required this._logger,
  });

  final AppLocalStorageService _localStorageService;
  final SupabaseService _supabaseService;
  final AppLoggerService _logger;

  Future<Either<AppError, List<SubjectEntity>>> getSubjects() async {
    try {
      final String? savedSubjects = await _localStorageService.read<String?>(
        LocalStorageKeys.subjects,
      );

      if (savedSubjects == null) {
        final List<SubjectEntity> remoteSubjects = await _getRemoteSubjects();
        if (remoteSubjects.isNotEmpty) {
          await _saveLocalSubjects(remoteSubjects);
        }
        return Right(remoteSubjects);
      }

      final List<dynamic> decoded = jsonDecode(savedSubjects) as List<dynamic>;
      final List<SubjectEntity> subjects = [];
      for (final dynamic item in decoded) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        // Skips entries from removed categories (e.g. the old "working" one).
        if (TimeCategoryType.tryByName(map["category"] as String? ?? "") ==
            null) {
          continue;
        }
        subjects.add(SubjectEntity.fromMap(map));
      }
      return Right(subjects);
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveSubjects(
    List<SubjectEntity> subjects,
  ) async {
    try {
      final String encoded = jsonEncode(
        subjects.map((subject) => subject.toMap()).toList(),
      );
      await _localStorageService.write(LocalStorageKeys.subjects, encoded);
      await _syncRemoteSubjects(subjects);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<void> _saveLocalSubjects(List<SubjectEntity> subjects) async {
    final String encoded = jsonEncode(
      subjects.map((subject) => subject.toMap()).toList(),
    );
    await _localStorageService.write(LocalStorageKeys.subjects, encoded);
  }

  Future<List<SubjectEntity>> _getRemoteSubjects() async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return const [];
    }

    try {
      final List<dynamic> rows = await _supabaseService.requireClient
          .from("user_subjects")
          .select()
          .eq("user_id", userId)
          .order("created_at");
      _logger.logResponse("select public.user_subjects", rows);

      return rows
          .map((row) => _subjectFromRow(row as Map<String, dynamic>))
          .where(
            (subject) =>
                TimeCategoryType.tryByName(subject.category.name) != null,
          )
          .toList();
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to fetch remote user_subjects",
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<void> _syncRemoteSubjects(List<SubjectEntity> subjects) async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final client = _supabaseService.requireClient;
      final List<Map<String, dynamic>> rows = subjects
          .map((subject) => _subjectToRow(subject, userId))
          .toList();

      if (rows.isNotEmpty) {
        await client
            .from("user_subjects")
            .upsert(rows, onConflict: "user_id,id");
      }

      final List<String> ids = subjects.map((subject) => subject.id).toList();
      var delete = client.from("user_subjects").delete().eq("user_id", userId);
      if (ids.isNotEmpty) {
        delete = delete.not("id", "in", "(${ids.join(",")})");
      }
      await delete;
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to sync remote user_subjects",
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }
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
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    };
    final DateTime? createdAt = subject.createdAt;
    if (createdAt != null) {
      row["created_at"] = createdAt.toUtc().toIso8601String();
    }
    return row;
  }
}
