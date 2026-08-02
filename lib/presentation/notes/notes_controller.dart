import "dart:async";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/use_cases/update_subject_notes_use_case.dart";
import "package:help_out/presentation/notes/notes_pages_codec.dart";

enum NotesSaveState { idle, saving, saved }

class NotesController extends GetxController {
  NotesController({
    required this._updateSubjectNotesUseCase,
    required this._appNavigator,
    required this.subject,
  });

  /// Long enough to avoid a write per keystroke, short enough that leaving the
  /// page never loses more than a moment of typing.
  static const Duration autoSaveDelay = Duration(milliseconds: 900);

  final UpdateSubjectNotesUseCase _updateSubjectNotesUseCase;
  final AppNavigator _appNavigator;

  final SubjectEntity subject;
  late final PageController pageController = PageController();
  late final RxList<TextEditingController> notesControllers =
      NotesPagesCodec.decode(
        subject.notes,
      ).map((String page) => TextEditingController(text: page)).toList().obs;
  final RxInt currentPageIndex = 0.obs;
  final Rx<NotesSaveState> saveState = NotesSaveState.idle.obs;

  Timer? _autoSaveTimer;
  String? _lastSavedNotes;

  int get pageCount => notesControllers.length;

  @override
  void onInit() {
    super.onInit();
    _lastSavedNotes = _currentNotes;
    for (final TextEditingController controller in notesControllers) {
      controller.addListener(_scheduleAutoSave);
    }
  }

  void onPageChanged(int index) => currentPageIndex.value = index;

  void previousPage() {
    if (currentPageIndex.value == 0) {
      return;
    }
    _goToPage(currentPageIndex.value - 1);
  }

  void nextPage() {
    if (currentPageIndex.value >= pageCount - 1) {
      return;
    }
    _goToPage(currentPageIndex.value + 1);
  }

  void addPage() {
    notesControllers.add(TextEditingController()..addListener(_scheduleAutoSave));
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

  /// Flushes anything still pending before handing the result back to the
  /// caller, so leaving the page never drops the last edit.
  Future<void> onBack() async {
    _autoSaveTimer?.cancel();
    await _save();
    _appNavigator.back<String>(result: _currentNotes);
  }

  void _goToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _scheduleAutoSave() {
    if (_currentNotes == _lastSavedNotes) {
      return;
    }
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(autoSaveDelay, _save);
  }

  Future<void> _save() async {
    final String notes = _currentNotes;
    if (notes == _lastSavedNotes || saveState.value == NotesSaveState.saving) {
      return;
    }

    saveState.value = NotesSaveState.saving;
    final result = await _updateSubjectNotesUseCase(
      subjectId: subject.id,
      notes: notes,
    );

    result.fold(
      (error) {
        saveState.value = NotesSaveState.idle;
        _appNavigator.showErrorSnackBar(error.message);
      },
      (_) {
        _lastSavedNotes = notes;
        saveState.value = NotesSaveState.saved;
      },
    );
  }

  String get _currentNotes => NotesPagesCodec.encode(
    notesControllers.map((controller) => controller.text),
  );

  @override
  void onClose() {
    _autoSaveTimer?.cancel();
    pageController.dispose();
    for (final TextEditingController controller in notesControllers) {
      controller
        ..removeListener(_scheduleAutoSave)
        ..dispose();
    }
    super.onClose();
  }
}
