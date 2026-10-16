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

    test("reads a goal cached with the former group ownership fields", () {
      final DailyTaskEntity goal = DailyTaskEntity.fromMap(const {
        "id": "1",
        "name": "Estudar",
        "colorValue": 1,
        "targetDays": 5,
        "completedDates": <String>[],
        "groupId": "group-123",
        "groupActivityId": "activity-1",
      });

      expect(goal.name, "Estudar");
      expect(goal.toMap().keys, isNot(contains("groupId")));
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

  group("DailyTaskEntity next unchecked time", () {
    DailyTaskEntity goal({List<String> done = const []}) => DailyTaskEntity(
      id: "1",
      name: "Beber água",
      colorValue: 1,
      targetDays: 0,
      completedDates: done,
    );

    const int noon = 12 * 60;
    final DateTime morning = DateTime(2026, 10, 7, 9);
    final String today = DailyTaskEntity.dateKey(morning);

    test("is today while unchecked and the time is still ahead", () {
      expect(goal().nextUncheckedAt(morning, noon), DateTime(2026, 10, 7, 12));
    });

    test("moves to tomorrow once the goal is checked today", () {
      expect(
        goal(done: [today]).nextUncheckedAt(morning, noon),
        DateTime(2026, 10, 8, 12),
      );
    });

    test("moves to tomorrow once today's time has passed", () {
      expect(
        goal().nextUncheckedAt(DateTime(2026, 10, 7, 12), noon),
        DateTime(2026, 10, 8, 12),
      );
    });

    test("a check from another day does not skip today", () {
      expect(
        goal(done: ["2026-10-06"]).nextUncheckedAt(morning, noon),
        DateTime(2026, 10, 7, 12),
      );
    });

    test("rolls over the end of a month", () {
      expect(
        goal().nextUncheckedAt(DateTime(2026, 10, 31, 22), 21 * 60),
        DateTime(2026, 11, 1, 21),
      );
    });
  });
}
