import "package:get/get.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/presentation/category/category_controller.dart";

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
        subjectDailyHistoryService: Get.find(),
        appNavigator: Get.find(),
        category: category,
      ),
    );
  }
}
