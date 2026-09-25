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
import "package:timing/presentation/notes/notes_pages_codec.dart";
import "package:timing/presentation/notes/notes_rich_text_codec.dart";
import "package:timing/theme/colors.dart";
import "package:timing/theme/theme.dart";

class _FakeUpdateSubjectNotesUseCase implements UpdateSubjectNotesUseCase {
  String? savedNotes;

  @override
  Future<Either<AppError, void>> call({
    required String subjectId,
    required String notes,
  }) async {
    savedNotes = notes;
    return const Right(null);
  }
}

class _FakeAppNavigator implements AppNavigator {
  Object? backResult;

  @override
  void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) {
    backResult = result;
  }

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  // flutter_quill's editor answers every controller notification that is not
  // flagged with `ignoreFocusOnTextChange` by requesting the keyboard whenever
  // it is hidden (and it treats `flutter test` as a keyboard OS, so the real
  // keyboard cannot be observed here). Recording that flag is therefore the
  // way to assert that a page change does not bring the keyboard up.
  test("changing page does not ask the new page's editor for the keyboard", () {
    final NotesController controller = NotesController(
      updateSubjectNotesUseCase: _FakeUpdateSubjectNotesUseCase(),
      appNavigator: _FakeAppNavigator(),
      subject: _notesSubject(
        NotesPagesCodec.encode(["First page", "Second page"]),
      ),
    );
    Get.put<NotesController>(controller);

    final QuillController secondPage = controller.notesControllers[1];
    final List<bool> requestedKeyboard = [];
    secondPage.addListener(
      () => requestedKeyboard.add(!secondPage.ignoreFocusOnTextChange),
    );

    controller.onPageChanged(1);

    expect(requestedKeyboard, isNotEmpty);
    expect(requestedKeyboard, everyElement(isFalse));
    // The flag must not stay on, or typing on that page would stop scrolling
    // the caret into view.
    expect(secondPage.ignoreFocusOnTextChange, isFalse);
  });

  testWidgets("moving between pages never asks an editor for the keyboard", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final NotesController controller = NotesController(
      updateSubjectNotesUseCase: _FakeUpdateSubjectNotesUseCase(),
      appNavigator: _FakeAppNavigator(),
      subject: _notesSubject(NotesPagesCodec.encode(["First page", "Second"])),
    );
    Get.put<NotesController>(controller);

    final List<bool> requestedKeyboard = [];
    final Set<QuillController> observed = {};
    void observeAll() {
      for (final QuillController page in controller.notesControllers) {
        if (observed.add(page)) {
          page.addListener(
            () => requestedKeyboard.add(!page.ignoreFocusOnTextChange),
          );
        }
      }
    }

    observeAll();
    ever(controller.notesControllers, (_) => observeAll());

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

    final Finder nextButton = find.widgetWithIcon(
      IconButton,
      Icons.chevron_right_rounded,
    );
    final Finder previousButton = find.widgetWithIcon(
      IconButton,
      Icons.chevron_left_rounded,
    );

    // Existing page, then a brand new one past the end, then back again.
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.text("2 / 2"), findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.text("3 / 3"), findsOneWidget);

    await tester.tap(previousButton);
    await tester.pumpAndSettle();

    expect(requestedKeyboard, isNotEmpty);
    expect(requestedKeyboard, everyElement(isFalse));
    for (final FocusNode node in controller.focusNodes) {
      expect(node.hasFocus, isFalse);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets("formats selected note text with toolbar actions", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);

    final _FakeUpdateSubjectNotesUseCase updateNotes =
        _FakeUpdateSubjectNotesUseCase();
    final _FakeAppNavigator navigator = _FakeAppNavigator();
    final NotesController controller = NotesController(
      updateSubjectNotesUseCase: updateNotes,
      appNavigator: navigator,
      subject: const SubjectEntity(
        id: "subject-1",
        name: "Study",
        category: TimeCategoryType.studying,
        colorValue: 1,
        totalSeconds: 0,
        goalSeconds: 0,
        currentPages: 0,
        goalPages: 0,
        notes: "Important",
        iconName: "",
        restMinutes: 5,
        focusSessionCount: 1,
        wallpaperIndex: 0,
      ),
    );
    Get.put<NotesController>(controller);

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

    expect(find.byType(QuillEditor), findsOneWidget);
    expect(
      find.byKey(const ValueKey("notes-formatting-toolbar")),
      findsNothing,
    );
    expect(find.byKey(const ValueKey("notes-format-bold")), findsNothing);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey("notes-format-bold")), findsOneWidget);
    expect(find.byKey(const ValueKey("notes-format-italic")), findsOneWidget);
    expect(
      find.byKey(const ValueKey("notes-format-underline")),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey("notes-format-marker")), findsOneWidget);
    expect(find.byKey(const ValueKey("notes-format-strike")), findsOneWidget);

    final QuillEditor editor = tester.widget<QuillEditor>(
      find.byType(QuillEditor),
    );
    expect(editor.config.showCursor, isTrue);
    expect(editor.config.paintCursorAboveText, isTrue);
    expect(editor.config.onTapOutsideEnabled, isFalse);
    expect(editor.config.textSelectionThemeData?.cursorColor, isNotNull);

    await tester.tap(find.byType(QuillEditor));
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);

    final QuillController quillController = controller.notesControllers.first;
    quillController.formatText(0, 9, Attribute.bold);
    quillController.updateSelection(
      const TextSelection.collapsed(offset: 4),
      ChangeSource.local,
    );
    await tester.pump();
    expect(
      quillController.document.collectStyle(0, 9).attributes,
      contains(Attribute.bold.key),
    );
    expect(controller.isFormattingActive(Attribute.bold), isFalse);
    expect(
      quillController.getSelectionStyle().attributes,
      isNot(contains(Attribute.bold.key)),
    );

    final Rect toolbarRectBeforeKeyboard = tester.getRect(
      find.byKey(const ValueKey("notes-formatting-toolbar")),
    );
    final Rect pageControlsRectBeforeKeyboard = tester.getRect(
      find.byKey(const ValueKey("notes-page-controls")),
    );

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    final Rect toolbarRect = tester.getRect(
      find.byKey(const ValueKey("notes-formatting-toolbar")),
    );
    final Rect pageControlsRect = tester.getRect(
      find.byKey(const ValueKey("notes-page-controls")),
    );
    expect(find.text("1 / 1"), findsOneWidget);
    expect(toolbarRect.width, closeTo(pageControlsRect.width, 1));
    expect(toolbarRect.bottom, lessThan(pageControlsRect.top));
    expect(toolbarRect.top, lessThan(toolbarRectBeforeKeyboard.top));
    expect(toolbarRect.bottom, lessThanOrEqualTo(900 - 300));
    expect(pageControlsRect, pageControlsRectBeforeKeyboard);

    controller.notesControllers.first.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 9),
      ChangeSource.local,
    );
    await tester.tap(find.byKey(const ValueKey("notes-format-bold")));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey("notes-format-strike")));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey("notes-format-marker")));
    await tester.pumpAndSettle();

    final Finder noColorSwatch = find.byKey(
      const ValueKey("notes-highlight-none"),
    );
    expect(noColorSwatch, findsOneWidget);
    final Container noColorContainer = tester.widget<Container>(
      find
          .descendant(of: noColorSwatch, matching: find.byType(Container))
          .first,
    );
    final BoxDecoration noColorDecoration =
        noColorContainer.decoration! as BoxDecoration;
    final AppColorTokens colorTokens = Theme.of(
      tester.element(noColorSwatch),
    ).extension<AppColorTokens>()!;
    expect(noColorDecoration.color, colorTokens.white);
    expect(noColorDecoration.border, isNull);
    final Finder blueSwatch = find.byKey(
      const ValueKey("notes-highlight-cde4f9"),
    );
    expect(blueSwatch, findsOneWidget);
    expect(
      tester.widget<BottomSheet>(find.byType(BottomSheet)).backgroundColor,
      Theme.of(
        tester.element(find.byType(BottomSheet)),
      ).extension<AppColorTokens>()!.surface,
    );
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );

    await tester.tap(blueSwatch);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey("notes-highlight-none")), findsNothing);

    final Map<String, Attribute<dynamic>> attributes = controller
        .notesControllers
        .first
        .getSelectionStyle()
        .attributes;
    expect(attributes, contains(Attribute.bold.key));
    expect(attributes, contains(Attribute.strikeThrough.key));
    expect(attributes[Attribute.background.key]?.value, "#cde4f9");

    await controller.onBack();

    final String savedNotes = updateNotes.savedNotes!;
    final Document savedDocument = NotesRichTextCodec.decode(
      NotesPagesCodec.decode(savedNotes).single,
    );
    final Map<String, Attribute<dynamic>> savedAttributes = savedDocument
        .collectStyle(0, 9)
        .attributes;
    expect(savedAttributes, contains(Attribute.bold.key));
    expect(savedAttributes, contains(Attribute.strikeThrough.key));
    expect(savedAttributes[Attribute.background.key]?.value, "#cde4f9");
    expect(navigator.backResult, savedNotes);
    expect(tester.takeException(), isNull);
  });

  testWidgets("creates a page past the last one and drops it if left empty", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final NotesController controller = NotesController(
      updateSubjectNotesUseCase: _FakeUpdateSubjectNotesUseCase(),
      appNavigator: _FakeAppNavigator(),
      subject: const SubjectEntity(
        id: "subject-1",
        name: "Study",
        category: TimeCategoryType.studying,
        colorValue: 1,
        totalSeconds: 0,
        goalSeconds: 0,
        currentPages: 0,
        goalPages: 0,
        notes: "",
        iconName: "",
        restMinutes: 5,
        focusSessionCount: 1,
        wallpaperIndex: 0,
      ),
    );
    Get.put<NotesController>(controller);

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

    final Finder nextButton = find.widgetWithIcon(
      IconButton,
      Icons.chevron_right_rounded,
    );
    final Finder previousButton = find.widgetWithIcon(
      IconButton,
      Icons.chevron_left_rounded,
    );

    expect(find.text("1 / 1"), findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(controller.pageCount, 2);
    expect(find.text("2 / 2"), findsOneWidget);

    await tester.tap(previousButton);
    await tester.pumpAndSettle();

    expect(controller.pageCount, 1);
    expect(find.text("1 / 1"), findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(controller.pageCount, 2);
    controller.notesControllers[1].document.insert(0, "Hi");
    await tester.pump();

    await tester.tap(previousButton);
    await tester.pumpAndSettle();

    expect(controller.pageCount, 2);
    expect(find.text("1 / 2"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
