import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";

void main() {
  group("DailyTaskEntity", () {
    test("maps legacy goal types to the new sequence types", () {
      final DailyTaskEntity intense = DailyTaskEntity.fromMap({
        "id": "1",
        "name": "Treinar",
        "colorValue": 123,
        "targetDays": 7,
        "completedDates": const <String>[],
        "goalType": "daily",
      });
      final DailyTaskEntity casual = DailyTaskEntity.fromMap({
        "id": "2",
        "name": "Ler",
        "colorValue": 456,
        "targetDays": 7,
        "completedDates": const <String>[],
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
      final DailyTaskEntity groupGoal = DailyTaskEntity(
        id: "1",
        name: "Estudar",
        colorValue: 1,
        targetDays: 5,
        completedDates: const [],
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
      final DailyTaskEntity goal = DailyTaskEntity(
        id: "1",
        name: "Estudar",
        colorValue: 1,
        targetDays: 5,
        completedDates: const [],
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
}
