import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/group_activity_draft.dart";
import "package:timing/core/domain/enums/time_category_type.dart";

void main() {
  group("GroupActivityDraft", () {
    test("subject payload uses the snake_case keys the RPC materializes", () {
      const GroupActivityDraft draft = GroupActivityDraft.subject(
        name: "Cálculo",
        category: TimeCategoryType.studying,
        colorValue: 4280391411,
        goalSeconds: 1800,
        goalPages: 0,
        iconName: "studing",
        restMinutes: 60,
        focusSessionCount: 2,
        wallpaperIndex: 3,
      );

      expect(draft.kindName, "subject");
      expect(draft.toPayload(), {
        "name": "Cálculo",
        "category": "studying",
        "color_value": 4280391411,
        "goal_seconds": 1800,
        "goal_pages": 0,
        "icon_name": "studing",
        "rest_minutes": 60,
        "focus_session_count": 2,
        "wallpaper_index": 3,
        "activity_type": "daily",
      });
    });

    test("goal payload carries only the goal fields", () {
      const GroupActivityDraft draft = GroupActivityDraft.goal(
        name: "Ler todo dia",
        colorValue: 123,
        targetDays: 30,
        goalType: "daily",
      );

      expect(draft.kindName, "goal");
      expect(draft.toPayload(), {
        "name": "Ler todo dia",
        "color_value": 123,
        "target_days": 30,
        "sequence_type": "casual",
        "goal_type": "daily",
      });
    });
  });
}
