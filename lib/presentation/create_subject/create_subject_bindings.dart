import "package:get/get.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/presentation/create_subject/create_subject_controller.dart";

class CreateSubjectBindings extends Bindings {
  @override
  void dependencies() {
    final TimeCategoryType category = Get.arguments as TimeCategoryType;

    Get.put<CreateSubjectController>(
      CreateSubjectController(
        addSubjectUseCase: Get.find(),
        appNavigator: Get.find(),
        category: category,
      ),
    );
  }
}
