import "package:get/get.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/app/route_arguments.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/presentation/category/category_controller.dart";

class CategoryBindings extends Bindings {
  @override
  void dependencies() {
    final TimeCategoryType category = RouteArguments.of<TimeCategoryType>(
      AppRoutes.category,
    );

    Get.put<CategoryController>(
      CategoryController(
        getSubjectsUseCase: Get.find(),
        deleteSubjectUseCase: Get.find(),
        pinSubjectToStartUseCase: Get.find(),
        appNavigator: Get.find(),
        category: category,
      ),
    );
  }
}
