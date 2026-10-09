import "package:get/get.dart";
import "package:timing/presentation/friends/friends_controller.dart";

class FriendsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<FriendsController>(
      FriendsController(
        socialStore: Get.find(),
        friendsRepository: Get.find(),
        groupsRepository: Get.find(),
        appController: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
