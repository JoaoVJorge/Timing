import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/update_subject_notes_use_case.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/notes/notes_controller.dart";
import "package:timing/presentation/notes/notes_page.dart";
import "package:timing/presentation/notes/notes_page_search.dart";
import "package:timing/presentation/notes/notes_pages_codec.dart";
import "package:timing/theme/theme.dart";

class _FakeUpdateSubjectNotesUseCase implements UpdateSubjectNotesUseCase {
  @override
  Future<Either<AppError, void>> call({
    required String subjectId,
    required String notes,
  }) async => const Right(null);
}

class _FakeAppNavigator implements AppNavigator {
  @override
  void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SubjectEntity _notesSubject(String notes) => SubjectEntity(
  id: "subject-1",
  name: "Study",
  category: TimeCategoryType.studying,
  colorValue: 1,
  totalSeconds: 0,
  goalSeconds: 0,
  currentPages: 0,
  goalPages: 0,
  notes: notes,
  iconName: "",
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
);

NotesController _putController() {
  final NotesController controller = NotesController(
    updateSubjectNotesUseCase: _FakeUpdateSubjectNotesUseCase(),
    appNavigator: _FakeAppNavigator(),
    subject: _notesSubject(
      NotesPagesCodec.encode([
        "Primeira pagina do caderno",
        "Segunda pagina com Sansao",
        "Terceira pagina de anotacoes",
      ]),
    ),
  );

  return Get.put<NotesController>(controller);
}

Future<void> _pumpNotesPage(
  WidgetTester tester, {
  Size size = const Size(430, 900),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    GetMaterialApp(
      locale: const Locale("pt"),
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      home: const NotesPage(),
    ),
  );
  await tester.pump();
}

/// The chip row scrolls sideways, so a chip is brought on screen before it is
/// tapped.
Future<void> _tapFilter(WidgetTester tester, String filter) async {
  final Finder chip = find.byKey(
    ValueKey<String>("notes-pages-filter-$filter"),
  );
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test("summarizes a page by its text, length and highlights", () {
    final Document document = Document()..insert(0, "Uma  anotacao\nqualquer");
    document.format(0, 3, const BackgroundAttribute("#cde4f9"));

    final NotesPageSummary summary = NotesPageSummary.of(2, document);

    expect(summary.index, 2);
    expect(summary.text, "Uma anotacao qualquer");
    expect(summary.wordCount, 3);
    expect(summary.hasHighlight, isTrue);
    expect(summary.isEmpty, isFalse);
    expect(
      summary.matches(filter: NotesPageFilter.highlighted, query: "ANOTACAO"),
      isTrue,
    );
    expect(summary.matches(filter: NotesPageFilter.empty, query: ""), isFalse);
  });

  test("moves the preview onto the match of a long page", () {
    final NotesPageSummary summary = NotesPageSummary.of(
      0,
      Document()
        ..insert(0, "${"palavra " * 40}Sansao venceu ${"depois " * 40}"),
    );

    final String preview = summary.preview("sansao");

    expect(preview, startsWith("…"));
    expect(preview, contains("Sansao venceu"));
    expect(preview.length, lessThanOrEqualTo(82));
    expect(summary.preview(""), startsWith("palavra"));
  });

  testWidgets("searches the pages from the page counter and jumps to one", (
    tester,
  ) async {
    final NotesController controller = _putController();
    await _pumpNotesPage(tester);

    expect(find.text("1 / 3"), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey("notes-page-picker")));
    await tester.pumpAndSettle();

    expect(find.text("Filtros e busca"), findsOneWidget);
    expect(find.byKey(const ValueKey("notes-page-row-0")), findsOneWidget);
    expect(find.byKey(const ValueKey("notes-page-row-1")), findsOneWidget);
    expect(find.byKey(const ValueKey("notes-page-row-2")), findsOneWidget);
    expect(find.text("Página 2"), findsOneWidget);
    expect(find.text("4 palavras"), findsNWidgets(3));

    await tester.enterText(
      find.byKey(const ValueKey("notes-pages-search-field")),
      "sansao",
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey("notes-page-row-0")), findsNothing);
    expect(find.byKey(const ValueKey("notes-page-row-1")), findsOneWidget);
    expect(find.byKey(const ValueKey("notes-page-row-2")), findsNothing);

    await tester.tap(find.byKey(const ValueKey("notes-page-row-1")));
    await tester.pumpAndSettle();

    expect(find.text("Filtros e busca"), findsNothing);
    expect(controller.currentPageIndex.value, 1);
    expect(find.text("2 / 3"), findsOneWidget);
  });

  testWidgets("filters the page list and says when nothing is left", (
    tester,
  ) async {
    _putController();
    await _pumpNotesPage(tester);

    await tester.tap(find.byKey(const ValueKey("notes-page-picker")));
    await tester.pumpAndSettle();

    await _tapFilter(tester, "withText");
    expect(find.byKey(const ValueKey("notes-page-row-2")), findsOneWidget);

    await _tapFilter(tester, "empty");

    expect(find.byKey(const ValueKey("notes-page-row-0")), findsNothing);
    expect(find.text("Nenhuma página encontrada"), findsOneWidget);
  });

  testWidgets("fits a small screen while the keyboard is up", (tester) async {
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);

    _putController();
    await _pumpNotesPage(tester, size: const Size(375, 667));

    await tester.tap(find.byKey(const ValueKey("notes-page-picker")));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    final Rect sheetRect = tester.getRect(find.byType(BottomSheet));
    expect(sheetRect.bottom, lessThanOrEqualTo(667));
    expect(find.byKey(const ValueKey("notes-page-row-0")), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
