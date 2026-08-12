import "package:get/get.dart";
import "package:timing/app/app_controller.dart";

class SplashController extends GetxController {
  SplashController({required this._appController});

  final AppController _appController;

  @override
  void onReady() {
    super.onReady();
    _appController.initialize();
  }
}
