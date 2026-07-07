import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/last_activity_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";

class HomeController extends GetxController {
  HomeController({
    required this._appController,
    required this._appNavigator,
    required this._lastActivityService,
  });

  final AppController _appController;
  final AppNavigator _appNavigator;
  final LastActivityService _lastActivityService;

  RxString get userName => _appController.userName;

  Rx<LastActivityEntity?> get lastActivity =>
      _lastActivityService.lastActivity;

  void onTapCategory(TimeCategoryType category) =>
      _appNavigator.toNamed(AppRoutes.category, arguments: category);

  void onTapDailyGoals() => _appNavigator.toNamed(AppRoutes.dailyGoals);
}
