import "package:get/get.dart";
import "package:help_out/presentation/category/category_controller.dart";

class CategoryBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CategoryController>(
      CategoryController(getSubjectsUseCase: Get.find(), addSubjectUseCase: Get.find(), appNavigator: Get.find()),
    );
  }
}
