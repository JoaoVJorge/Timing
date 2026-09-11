import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/use_cases/update_subject_notes_use_case.dart";
import "package:timing/presentation/notes/notes_pages_codec.dart";
import "package:timing/presentation/notes/notes_rich_text_codec.dart";

enum NotesSaveState { idle, saving, saved }

class NotesController extends GetxController {
  NotesController({
    required this._updateSubjectNotesUseCase,
    required this._appNavigator,
    required this.subject,
  });

  final UpdateSubjectNotesUseCase _updateSubjectNotesUseCase;
  final AppNavigator _appNavigator;
  static final List<Attribute<dynamic>> _formattingAttributes = [
    Attribute.bold,
    Attribute.italic,
    Attribute.underline,
    Attribute.strikeThrough,
  ];
  final Set<String> _activeFormattingKeys = <String>{};
  Color? _activeHighlightColor;

  final SubjectEntity subject;
  late final PageController pageController = PageController();
  late final RxList<QuillController> notesControllers =
      NotesPagesCodec.decode(subject.notes)
          .map(
            (String page) => _createNotesController(
              document: NotesRichTextCodec.decode(page),
            ),
          )
          .toList()
          .obs;
  final RxInt currentPageIndex = 0.obs;
  final Rx<NotesSaveState> saveState = NotesSaveState.idle.obs;
  final RxBool isFormattingToolbarVisible = false.obs;

  String? _lastSavedNotes;
  bool _isClosing = false;

  int get pageCount => notesControllers.length;

  QuillController get activeNotesController =>
      notesControllers[currentPageIndex.value];

  @override
  void onInit() {
    super.onInit();
    // Keep the raw stored value so legacy notebooks containing blank pages are
    // normalized the next time the user saves/closes them.
    _lastSavedNotes = subject.notes;
  }

  void onPageChanged(int index) {
    currentPageIndex.value = index;
    _applyFormattingState(activeNotesController);
  }

  bool isFormattingActive(Attribute<dynamic> attribute) =>
      _activeFormattingKeys.contains(attribute.key);

  Color? get activeHighlightColor => _activeHighlightColor;

  bool get isHighlightActive => _activeHighlightColor != null;

  void setHighlightColor(Color? color) {
    _activeHighlightColor = color;

    final QuillController quillController = activeNotesController;
    if (!quillController.selection.isCollapsed) {
      quillController.formatSelection(
        color == null
            ? Attribute.background
            : BackgroundAttribute(_toHex(color)),
      );
    }
    _applyFormattingState(quillController);
  }

  void toggleFormattingToolbar() {
    isFormattingToolbarVisible.toggle();
  }

  void toggleFormatting(Attribute<dynamic> attribute) {
    final bool shouldActivate = !isFormattingActive(attribute);
    if (shouldActivate) {
      _activeFormattingKeys.add(attribute.key);
    } else {
      _activeFormattingKeys.remove(attribute.key);
    }

    final QuillController quillController = activeNotesController;
    if (!quillController.selection.isCollapsed) {
      quillController.formatSelection(
        shouldActivate ? attribute : Attribute.clone(attribute, null),
      );
    }
    _applyFormattingState(quillController);
  }

  void previousPage() {
    if (currentPageIndex.value == 0) {
      return;
    }
    final int leavingIndex = currentPageIndex.value;
    final QuillController leavingController = notesControllers[leavingIndex];
    final bool isLeavingPageEmpty = NotesRichTextCodec.isEmpty(
      leavingController.document,
    );
    final int targetIndex = leavingIndex - 1;
    _goToPage(targetIndex).then((_) {
      if (!isLeavingPageEmpty) {
        return;
      }
      notesControllers.removeAt(leavingIndex);
      leavingController.dispose();
      currentPageIndex.value = targetIndex;
    });
  }

  void nextPage() {
    if (currentPageIndex.value >= pageCount - 1) {
      addPage();
      return;
    }
    _goToPage(currentPageIndex.value + 1);
  }

  void addPage() {
    notesControllers.add(_createNotesController(document: Document()));
    currentPageIndex.value = pageCount - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!pageController.hasClients) {
        return;
      }
      pageController.animateToPage(
        currentPageIndex.value,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> onBack() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;
    final bool didSave = await _save();
    if (!didSave) {
      _isClosing = false;
      return;
    }
    _appNavigator.back<String>(result: _currentNotes);
  }

  Future<void> _goToPage(int index) => pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOut,
  );

  QuillController _createNotesController({required Document document}) {
    late final QuillController controller;
    controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      onSelectionChanged: (_) => _applyFormattingState(controller),
    );
    _applyFormattingState(controller);
    return controller;
  }

  void _applyFormattingState(QuillController controller) {
    controller.forceToggledStyle(
      Style.attr({
        for (final Attribute<dynamic> attribute in _formattingAttributes)
          attribute.key: isFormattingActive(attribute)
              ? attribute
              : Attribute.clone(attribute, null),
        Attribute.background.key: _activeHighlightColor == null
            ? Attribute.background
            : BackgroundAttribute(_toHex(_activeHighlightColor!)),
      }),
    );
  }

  static String _toHex(Color color) =>
      "#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, "0")}";

  Future<bool> _save() async {
    final String notes = _currentNotes;
    if (notes == _lastSavedNotes || saveState.value == NotesSaveState.saving) {
      return true;
    }

    saveState.value = NotesSaveState.saving;
    final result = await _updateSubjectNotesUseCase(
      subjectId: subject.id,
      notes: notes,
    );

    return result.fold(
      (error) {
        saveState.value = NotesSaveState.idle;
        _appNavigator.showErrorSnackBar(error.message);
        return false;
      },
      (_) {
        _lastSavedNotes = notes;
        saveState.value = NotesSaveState.saved;
        return true;
      },
    );
  }

  String get _currentNotes => NotesPagesCodec.encode(
    notesControllers
        .where(
          (QuillController controller) =>
              !NotesRichTextCodec.isEmpty(controller.document),
        )
        .map(
          (QuillController controller) =>
              NotesRichTextCodec.encode(controller.document),
        ),
  );

  @override
  void onClose() {
    pageController.dispose();
    for (final QuillController controller in notesControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
