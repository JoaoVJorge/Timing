import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:help_out/presentation/progress/widgets/progress_achievements_section.dart";
import "package:help_out/presentation/progress/widgets/progress_evolution_chart.dart";
import "package:help_out/presentation/progress/widgets/progress_hero_card.dart";
import "package:help_out/presentation/progress/widgets/progress_stat_row.dart";
import "package:help_out/presentation/progress/widgets/progress_top_subjects_list.dart";

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
    expect(find.text("15m"), findsOneWidget);
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
        child: EvolutionBarChart(
          values: [600, 900, 0, 1200, 720, 1080, 300],
        ),
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

  testWidgets("ProgressTopSubjectsList shows its empty state", (tester) async {
    await pumpInScrollView(tester, const ProgressTopSubjectsList(subjects: []));

    expect(tester.takeException(), isNull);
  });
}
