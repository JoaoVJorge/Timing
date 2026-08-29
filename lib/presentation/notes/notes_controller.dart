import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/use_cases/update_subject_notes_use_case.dart";
import "package:timing/presentation/notes/notes_pages_codec.dart";

enum NotesSaveState { idle, saving, saved }

class NotesController extends GetxController {
  NotesController({
    required this._updateSubjectNotesUseCase,
    required this._appNavigator,
    required this.subject,
  });

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

  String? _lastSavedNotes;
  bool _isClosing = false;

  int get pageCount => notesControllers.length;

  @override
  void onInit() {
    super.onInit();
    // Keep the raw stored value so legacy notebooks containing blank pages are
    // normalized the next time the user saves/closes them.
    _lastSavedNotes = subject.notes;
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
    notesControllers.add(TextEditingController());
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

  void _goToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

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
    notesControllers.map((controller) => controller.text),
  );

  @override
  void onClose() {
    pageController.dispose();
    for (final TextEditingController controller in notesControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
