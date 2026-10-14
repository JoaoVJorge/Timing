import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/category/widgets/hobby_subject_card.dart";
import "package:timing/presentation/category/widgets/reading_subject_tile.dart";
import "package:timing/presentation/category/widgets/subject_tile.dart";
import "package:timing/theme/theme.dart";

void main() {
  testWidgets("the entire standard activity tile starts the activity", (
    tester,
  ) async {
    int starts = 0;
    const SubjectEntity subject = SubjectEntity(
      id: "study-1",
      name: "Matemática",
      category: TimeCategoryType.studying,
      colorValue: 0xFF4361EE,
      totalSeconds: 1200,
      goalSeconds: 3600,
      currentPages: 0,
      goalPages: 0,
      notes: "",
      iconName: "book",
      restMinutes: 5,
      focusSessionCount: 1,
      wallpaperIndex: 0,
    );

    await tester.pumpWidget(
      _TestApp(
        child: SubjectTile(
          subject: subject,
          currentSeconds: 1200,
          onTapPlay: () => starts++,
        ),
      ),
    );

    await tester.tap(find.text("Matemática"));
    await tester.pump();

    expect(starts, 1);
  });

  testWidgets("the entire reading activity tile starts the activity", (
    tester,
  ) async {
    int starts = 0;
    const SubjectEntity subject = SubjectEntity(
      id: "reading-1",
      name: "Livro",
      category: TimeCategoryType.reading,
      colorValue: 0xFF4361EE,
      totalSeconds: 1200,
      goalSeconds: 0,
      currentPages: 15,
      goalPages: 100,
      notes: "",
      iconName: "book",
      restMinutes: 5,
      focusSessionCount: 1,
      wallpaperIndex: 0,
    );

    await tester.pumpWidget(
      _TestApp(
        child: ReadingSubjectTile(
          subject: subject,
          currentSeconds: 1200,
          currentPages: 15,
          onTapPlay: () => starts++,
        ),
      ),
    );

    await tester.tap(find.text("Livro"));
    await tester.pump();

    expect(starts, 1);
  });

  testWidgets("hobby options open notes instead of pinning", (tester) async {
    bool didOpenNotes = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale("pt"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 210,
              height: 280,
              child: HobbySubjectCard(
                subject: const SubjectEntity(
                  id: "hobby-1",
                  name: "Violão",
                  category: TimeCategoryType.hobbies,
                  colorValue: 0xFF8E5BD9,
                  totalSeconds: 1200,
                  goalSeconds: 0,
                  currentPages: 0,
                  goalPages: 0,
                  notes: "",
                  iconName: "guitar",
                  restMinutes: 5,
                  focusSessionCount: 1,
                  wallpaperIndex: 0,
                ),
                onTapPlay: () {},
                onTapNotes: () => didOpenNotes = true,
                onTapStats: () {},
                onTapEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    expect(find.text("Ver notas"), findsOneWidget);
    expect(find.text("Fixar no início"), findsNothing);

    await tester.tap(find.text("Ver notas"));
    await tester.pumpAndSettle();

    expect(didOpenNotes, isTrue);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: const Locale("pt"),
    theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: Center(child: SizedBox(width: 430, child: child)),
    ),
  );
}
