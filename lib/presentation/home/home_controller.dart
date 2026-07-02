import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";

class HomeController extends GetxController {
  HomeController({required this._appController, required this._appNavigator});

  final AppController _appController;
  final AppNavigator _appNavigator;

  RxString get userName => _appController.userName;

  void onTapCategory(TimeCategoryType category) => _appNavigator.toNamed(AppRoutes.category, arguments: category);
}
