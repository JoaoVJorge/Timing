import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";

void main() {
  group("DailyTaskEntity", () {
    test("maps legacy goal types to the new sequence types", () {
      final DailyTaskEntity intense = DailyTaskEntity.fromMap(const {
        "id": "1",
        "name": "Treinar",
        "colorValue": 123,
        "targetDays": 7,
        "completedDates": <String>[],
        "goalType": "daily",
      });
      final DailyTaskEntity casual = DailyTaskEntity.fromMap(const {
        "id": "2",
        "name": "Ler",
        "colorValue": 456,
        "targetDays": 7,
        "completedDates": <String>[],
        "goalType": "total",
      });

      expect(intense.sequenceType, DailyTaskSequenceType.intense);
      expect(casual.sequenceType, DailyTaskSequenceType.casual);
    });

    test("intense sequence resets when yesterday was missed", () {
      final DateTime today = DateTime.now();
      final DailyTaskEntity task = DailyTaskEntity(
        id: "1",
        name: "Estudar",
        colorValue: 123,
        targetDays: 7,
        completedDates: [
          DailyTaskEntity.dateKey(today.subtract(const Duration(days: 2))),
        ],
        sequenceType: DailyTaskSequenceType.intense,
      );

      expect(task.currentProgress, 0);
      expect(task.shouldAskAboutMissedYesterday(today), true);
    });

    test("tracks group ownership and survives a map round-trip", () {
      final DailyTaskEntity groupGoal = const DailyTaskEntity(
        id: "1",
        name: "Estudar",
        colorValue: 1,
        targetDays: 5,
        completedDates: [],
        groupId: "group-123",
      );
      final DailyTaskEntity soloGoal = groupGoal.copyWith(name: "Ler");

      expect(groupGoal.isFromGroup, true);
      expect(DailyTaskEntity.fromMap(groupGoal.toMap()).groupId, "group-123");
      expect(DailyTaskEntity.fromMap(groupGoal.toMap()).isFromGroup, true);
      // copyWith keeps the group link.
      expect(soloGoal.isFromGroup, true);
    });

    test("a goal with no group is not locked", () {
      final DailyTaskEntity goal = const DailyTaskEntity(
        id: "1",
        name: "Estudar",
        colorValue: 1,
        targetDays: 5,
        completedDates: [],
      );

      expect(goal.isFromGroup, false);
      expect(DailyTaskEntity.fromMap(goal.toMap()).isFromGroup, false);
    });

    test("infinite targets are never auto-completed", () {
      final DailyTaskEntity task = DailyTaskEntity(
        id: "1",
        name: "Meditar",
        colorValue: 123,
        targetDays: 0,
        completedDates: [DailyTaskEntity.dateKey(DateTime.now())],
      );

      expect(task.hasInfiniteTarget, true);
      expect(task.isCompleted, false);
    });
  });

  group("DailyTaskEntity reminder", () {
    DailyTaskEntity goal({int? reminder, List<String> done = const []}) =>
        DailyTaskEntity(
          id: "1",
          name: "Beber água",
          colorValue: 1,
          targetDays: 0,
          completedDates: done,
          reminderMinutes: reminder,
        );

    final DateTime morning = DateTime(2026, 10, 7, 9);
    final String today = DailyTaskEntity.dateKey(morning);

    test("a goal without a reminder time is never due", () {
      expect(goal().nextReminderAt(morning), isNull);
    });

    test("is due today while unchecked and the time is still ahead", () {
      expect(
        goal(reminder: 12 * 60).nextReminderAt(morning),
        DateTime(2026, 10, 7, 12),
      );
    });

    test("moves to tomorrow once the goal is checked today", () {
      expect(
        goal(reminder: 12 * 60, done: [today]).nextReminderAt(morning),
        DateTime(2026, 10, 8, 12),
      );
    });

    test("moves to tomorrow once today's time has passed", () {
      expect(
        goal(reminder: 12 * 60).nextReminderAt(DateTime(2026, 10, 7, 12)),
        DateTime(2026, 10, 8, 12),
      );
    });

    test("a check from another day does not skip today", () {
      expect(
        goal(reminder: 12 * 60, done: ["2026-10-06"]).nextReminderAt(morning),
        DateTime(2026, 10, 7, 12),
      );
    });

    test("rolls over the end of a month", () {
      expect(
        goal(reminder: 8 * 60 + 30).nextReminderAt(DateTime(2026, 10, 31, 20)),
        DateTime(2026, 11, 1, 8, 30),
      );
    });

    test("survives a map round-trip and can be cleared", () {
      final DailyTaskEntity withReminder = goal(reminder: 7 * 60 + 15);

      expect(
        DailyTaskEntity.fromMap(withReminder.toMap()).reminderMinutes,
        7 * 60 + 15,
      );
      expect(withReminder.copyWith(name: "Outra").reminderMinutes, 7 * 60 + 15);
      expect(withReminder.copyWith(clearReminder: true).reminderMinutes, null);
    });

    test("ignores a stored time outside the day", () {
      final Map<String, dynamic> map = goal().toMap();

      expect(
        DailyTaskEntity.fromMap({
          ...map,
          "reminderMinutes": 1440,
        }).reminderMinutes,
        isNull,
      );
      expect(
        DailyTaskEntity.fromMap({
          ...map,
          "reminderMinutes": -1,
        }).reminderMinutes,
        isNull,
      );
    });
  });
}
