import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/presentation/notes/notes_controller.dart";

class NotesBindings extends Bindings {
  @override
  void dependencies() {
    final SubjectEntity subject = Get.arguments as SubjectEntity;

    Get.put<NotesController>(
      NotesController(
        updateSubjectNotesUseCase: Get.find(),
        appNavigator: Get.find(),
        subject: subject,
      ),
    );
  }
}
