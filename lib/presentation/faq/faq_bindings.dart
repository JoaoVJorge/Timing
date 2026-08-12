import "package:get/get.dart";
import "package:timing/presentation/faq/faq_controller.dart";

class FaqBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<FaqController>(FaqController());
  }
}
