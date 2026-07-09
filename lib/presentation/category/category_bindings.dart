import "package:get/get.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/presentation/category/category_controller.dart";

class CategoryBindings extends Bindings {
  @override
  void dependencies() {
    final TimeCategoryType category = Get.arguments as TimeCategoryType;

    Get.put<CategoryController>(
      CategoryController(
        getSubjectsUseCase: Get.find(),
        deleteSubjectUseCase: Get.find(),
        appNavigator: Get.find(),
        category: category,
      ),
    );
  }
}
