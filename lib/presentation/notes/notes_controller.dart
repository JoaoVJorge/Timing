import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/use_cases/update_subject_notes_use_case.dart";

class NotesController extends GetxController {
  NotesController({
    required this._updateSubjectNotesUseCase,
    required this._appNavigator,
    required this.subject,
  });

  final UpdateSubjectNotesUseCase _updateSubjectNotesUseCase;
  final AppNavigator _appNavigator;

  final SubjectEntity subject;
  late final TextEditingController notesController = TextEditingController(
    text: subject.notes,
  );

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  Future<void> onTapSave() async {
    final String notes = notesController.text;
    await _updateSubjectNotesUseCase(subjectId: subject.id, notes: notes);
    _appNavigator.back<String>(result: notes);
  }
}
