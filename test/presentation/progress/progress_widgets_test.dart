import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/presentation/progress/progress_controller.dart";
import "package:timing/presentation/progress/widgets/progress_achievements_section.dart";
import "package:timing/presentation/progress/widgets/progress_evolution_chart.dart";
import "package:timing/presentation/progress/widgets/progress_hero_card.dart";
import "package:timing/presentation/progress/widgets/progress_stat_row.dart";

import "../../support/pump_in_scroll_view.dart";

void main() {
  group("ProgressStatRow", () {
    testWidgets("lays out inside a scroll view", (tester) async {
      await pumpInScrollView(
        tester,
        const ProgressStatRow(
          stats: [
            (
              icon: Icons.auto_stories_rounded,
              value: "15",
              label: "Pages",
              accent: Colors.orange,
            ),
            (
              icon: Icons.fitness_center_rounded,
              value: "30m",
              label: "Reps",
              accent: Colors.green,
            ),
            (
              icon: Icons.task_alt_rounded,
              value: "2/4",
              label: "Goals",
              accent: Colors.blue,
            ),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text("15"), findsOneWidget);
    });

    testWidgets("lays out on a narrow screen with a wrapping label", (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpInScrollView(
        tester,
        const ProgressStatRow(
          stats: [
            (
              icon: Icons.auto_stories_rounded,
              value: "15",
              label: "Pages",
              accent: Colors.orange,
            ),
            (
              icon: Icons.fitness_center_rounded,
              value: "30m",
              label: "Exercises",
              accent: Colors.green,
            ),
            (
              icon: Icons.task_alt_rounded,
              value: "2/4",
              label: "Metas concluidas",
              accent: Colors.blue,
            ),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text("Metas concluidas"), findsOneWidget);
    });
  });

  testWidgets("ProgressHeroCard renders a comparison line", (tester) async {
    await pumpInScrollView(
      tester,
      const ProgressHeroCard(
        focusSeconds: 900,
        differenceToPreviousPeriod: 300,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("15 min"), findsOneWidget);
  });

  testWidgets("ProgressHeroCard handles a missing previous period", (
    tester,
  ) async {
    await pumpInScrollView(
      tester,
      const ProgressHeroCard(focusSeconds: 0, differenceToPreviousPeriod: null),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets("ProgressEvolutionChart paints an empty series", (tester) async {
    await pumpInScrollView(
      tester,
      const ProgressEvolutionChart(values: [0, 0, 0, 0, 0, 0, 0]),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets("EvolutionBarChart paints minutes and pages units", (
    tester,
  ) async {
    await pumpInScrollView(
      tester,
      const SizedBox(
        width: 320,
        height: 180,
        child: EvolutionBarChart(values: [600, 900, 0, 1200, 720, 1080, 300]),
      ),
    );
    expect(tester.takeException(), isNull);

    await pumpInScrollView(
      tester,
      const SizedBox(
        width: 320,
        height: 180,
        child: EvolutionBarChart(
          values: [2, 5, 0, 8, 3, 6, 1],
          unit: EvolutionValueUnit.pages,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  group("EvolutionBarChart highlight", () {
    /// What the chart paints: the card is a rounded rect plus an arrow path;
    /// the dot on top of the bar is three circles.
    RenderObject chartPaint(WidgetTester tester) => tester.renderObject(
      find
          .descendant(
            of: find.byType(EvolutionBarChart),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

    Future<void> pumpChart(WidgetTester tester, List<int> values) =>
        pumpInScrollView(
          tester,
          SizedBox(
            width: 320,
            height: 180,
            child: EvolutionBarChart(values: values),
          ),
        );

    testWidgets("a single day shows the card with its arrow but no dot", (
      tester,
    ) async {
      await pumpChart(tester, const [1200]);

      expect(chartPaint(tester), paints..path());
      expect(chartPaint(tester), isNot(paints..circle()));
    });

    testWidgets("several days keep the dot under the card", (tester) async {
      await pumpChart(tester, const [600, 900, 0, 1200, 720, 1080, 300]);

      expect(
        chartPaint(tester),
        paints
          ..path()
          ..circle()
          ..circle()
          ..circle(),
      );
    });

    testWidgets("a month keeps the dot too", (tester) async {
      await pumpChart(tester, List<int>.generate(30, (index) => index * 60));

      expect(
        chartPaint(tester),
        paints
          ..path()
          ..circle(),
      );
    });
  });

  testWidgets("ProgressAchievementsSection renders locked progress", (
    tester,
  ) async {
    await pumpInScrollView(
      tester,
      ProgressAchievementsSection(
        hasGoalStarted: false,
        hasValidFirstFocus: true,
        activeDays: 2,
        sessions: 3,
        readingPages: 12,
        focusSeconds: 38 * 60,
        onTap: () {},
      ),
    );

    expect(tester.takeException(), isNull);
  });

  group("activity summaries", () {
    test("group entries and keep time separate from pages", () {
      final DateTime now = DateTime(2026, 9, 25, 12);
      final List<ProgressActivitySummary> result =
          buildProgressActivitySummaries(
            subjects: const [
              _TestSubject(
                id: "math",
                name: "Matemática",
                category: TimeCategoryType.studying,
              ),
              _TestSubject(
                id: "gym",
                name: "Academia",
                category: TimeCategoryType.exercises,
              ),
              _TestSubject(
                id: "book",
                name: "Livro",
                category: TimeCategoryType.reading,
              ),
              _TestSubject(
                id: "other-book",
                name: "Outro livro",
                category: TimeCategoryType.reading,
              ),
            ],
            entries: [
              _activityEntry(
                id: "math-1",
                subjectId: "math",
                name: "Matemática",
                category: TimeCategoryType.studying,
                timestamp: now,
                seconds: 3600,
              ),
              _activityEntry(
                id: "math-2",
                subjectId: "math",
                name: "Matemática",
                category: TimeCategoryType.studying,
                timestamp: now,
                seconds: 1800,
              ),
              _activityEntry(
                id: "gym",
                subjectId: "gym",
                name: "Academia",
                category: TimeCategoryType.exercises,
                timestamp: now,
                seconds: 1800,
              ),
              _activityEntry(
                id: "book-1",
                subjectId: "book",
                name: "Livro",
                category: TimeCategoryType.reading,
                timestamp: now,
                seconds: 600,
                pages: 30,
              ),
              _activityEntry(
                id: "book-2",
                subjectId: "other-book",
                name: "Outro livro",
                category: TimeCategoryType.reading,
                timestamp: now,
                pages: 10,
              ),
            ],
          );

      expect(result, hasLength(4));
      expect(result.first.name, "Livro");
      expect(result.first.share, 0.75);

      final ProgressActivitySummary math = result.singleWhere(
        (activity) => activity.id == "math",
      );
      final ProgressActivitySummary gym = result.singleWhere(
        (activity) => activity.id == "gym",
      );
      expect(math.seconds, 5400);
      expect(math.share, 0.75);
      expect(gym.share, 0.25);
    });

    test("ignore history whose activity has been deleted", () {
      final List<ProgressActivitySummary> result =
          buildProgressActivitySummaries(
            subjects: const [],
            entries: [
              _activityEntry(
                id: "one",
                subjectId: "",
                name: "Atividade antiga",
                category: TimeCategoryType.hobbies,
                timestamp: DateTime(2026, 9, 25),
                seconds: 300,
              ),
              _activityEntry(
                id: "two",
                subjectId: "",
                name: "Atividade antiga",
                category: TimeCategoryType.hobbies,
                timestamp: DateTime(2026, 9, 25, 1),
                seconds: 300,
              ),
            ],
          );

      expect(result, isEmpty);
    });
  });
}

class _TestSubject extends SubjectEntity {
  const _TestSubject({
    required super.id,
    required super.name,
    required super.category,
  }) : super(
         colorValue: 0,
         totalSeconds: 0,
         goalSeconds: 0,
         currentPages: 0,
         goalPages: 0,
         notes: "",
         iconName: "",
         restMinutes: 5,
         focusSessionCount: 1,
         wallpaperIndex: 0,
       );
}

ActivityEntryEntity _activityEntry({
  required String id,
  required String subjectId,
  required String name,
  required TimeCategoryType category,
  required DateTime timestamp,
  int seconds = 0,
  int pages = 0,
}) => ActivityEntryEntity(
  id: id,
  category: category,
  subjectId: subjectId,
  subjectName: name,
  timestamp: timestamp,
  seconds: seconds,
  pages: pages,
);
