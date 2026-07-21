import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/use_cases/update_subject_notes_use_case.dart";
import "package:help_out/presentation/notes/notes_pages_codec.dart";

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
  final RxBool isSaving = false.obs;

  int get pageCount => notesControllers.length;

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

  void _goToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    for (final TextEditingController controller in notesControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> onTapSave() async {
    if (isSaving.value) {
      return;
    }

    isSaving.value = true;
    final String notes = NotesPagesCodec.encode(
      notesControllers.map((controller) => controller.text),
    );
    final result = await _updateSubjectNotesUseCase(
      subjectId: subject.id,
      notes: notes,
    );
    isSaving.value = false;

    result.fold(
      (error) => _appNavigator.showErrorSnackBar(error.message),
      (_) => _appNavigator.back<String>(result: notes),
    );
  }
}
