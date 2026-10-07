import "package:timing/core/domain/enums/time_category_type.dart";

enum GroupActivityKind { subject, goal }

/// Shared target chosen during group creation. The creator may link several
/// personal sources; a null sourceIds asks the backend to create one instead.
class GroupActivityDraft {
  const GroupActivityDraft.subject({
    required this.name,
    this.sourceIds,
    required TimeCategoryType this.category,
    required this.colorValue,
    this.goalSeconds = 0,
    this.goalPages = 0,
    this.iconName = "",
    this.restMinutes = 60,
    this.focusSessionCount = 1,
    this.wallpaperIndex = 0,
    this.activityType = "daily",
  }) : kind = GroupActivityKind.subject,
       targetDays = 0,
       sequenceType = "casual",
       goalType = "total";

  const GroupActivityDraft.goal({
    required this.name,
    this.sourceIds,
    required this.colorValue,
    this.targetDays = 0,
    this.sequenceType = "casual",
    this.goalType = "total",
  }) : kind = GroupActivityKind.goal,
       category = null,
       goalSeconds = 0,
       goalPages = 0,
       iconName = "",
       restMinutes = 60,
       focusSessionCount = 1,
       wallpaperIndex = 0,
       activityType = "daily";

  /// Null creates a personal activity; otherwise link these existing sources.
  final List<String>? sourceIds;

  final GroupActivityKind kind;
  final String name;
  final int colorValue;
  final TimeCategoryType? category;
  final int goalSeconds;
  final int goalPages;
  final String iconName;
  final int restMinutes;
  final int focusSessionCount;
  final int wallpaperIndex;
  final int targetDays;
  final String activityType;
  final String sequenceType;
  final String goalType;

  String get kindName => kind.name;

  Map<String, dynamic> toPayload() => switch (kind) {
    GroupActivityKind.subject => {
      "name": name,
      if (sourceIds != null) "source_ids": sourceIds,
      "category": (category ?? TimeCategoryType.studying).name,
      "color_value": colorValue,
      "goal_seconds": goalSeconds,
      "goal_pages": goalPages,
      "icon_name": iconName,
      "rest_minutes": restMinutes,
      "focus_session_count": focusSessionCount,
      "wallpaper_index": wallpaperIndex,
      "activity_type": activityType,
    },
    GroupActivityKind.goal => {
      "name": name,
      if (sourceIds != null) "source_ids": sourceIds,
      "color_value": colorValue,
      "target_days": targetDays,
      "sequence_type": sequenceType,
      "goal_type": goalType,
    },
  };
}
