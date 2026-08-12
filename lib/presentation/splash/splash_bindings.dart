import "package:get/get.dart";
import "package:timing/presentation/splash/splash_controller.dart";

class SplashBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController(appController: Get.find()));
  }
}
