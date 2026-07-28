import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/presentation/create_subject/create_subject_controller.dart";

class CreateSubjectBindings extends Bindings {
  @override
  void dependencies() {
    final Object? arguments = Get.arguments;
    final SubjectEntity? subject = arguments is SubjectEntity
        ? arguments
        : null;
    final TimeCategoryType category =
        subject?.category ?? arguments as TimeCategoryType;

    Get.put<CreateSubjectController>(
      CreateSubjectController(
        addSubjectUseCase: Get.find(),
        updateSubjectUseCase: Get.find(),
        appNavigator: Get.find(),
        category: category,
        editingSubject: subject,
      ),
    );
  }
}
