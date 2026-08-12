import "package:get/get.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/presentation/notes/notes_controller.dart";

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
