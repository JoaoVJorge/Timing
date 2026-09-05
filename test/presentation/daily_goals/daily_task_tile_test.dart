import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/daily_goals/widgets/daily_task_tile.dart";
import "package:timing/theme/theme.dart";

void main() {
  testWidgets("tapping the goal tile toggles it", (tester) async {
    int toggles = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale("pt"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: DailyTaskTile(
            task: const DailyTaskEntity(
              id: "goal-1",
              name: "Beber água",
              colorValue: 0xFF4C84FF,
              targetDays: 7,
              completedDates: [],
            ),
            onEdit: () {},
            onToggle: () async => toggles++,
            onDelete: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text("Beber água"));
    await tester.pumpAndSettle();

    expect(toggles, 1);
  });
}
