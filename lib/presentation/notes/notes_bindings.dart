import "package:get/get.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/app/route_arguments.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/presentation/notes/notes_controller.dart";

class NotesBindings extends Bindings {
  @override
  void dependencies() {
    final SubjectEntity subject = RouteArguments.of<SubjectEntity>(
      AppRoutes.notes,
    );

    Get.put<NotesController>(
      NotesController(
        updateSubjectNotesUseCase: Get.find(),
        appNavigator: Get.find(),
        subject: subject,
      ),
    );
  }
}
