import "package:get/get.dart";
import "package:help_out/presentation/friends/friends_controller.dart";

class FriendsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<FriendsController>(
      FriendsController(
        getFriendsSocialUseCase: Get.find(),
        sendFriendRequestUseCase: Get.find(),
        acceptFriendRequestUseCase: Get.find(),
        declineFriendRequestUseCase: Get.find(),
        cancelFriendRequestUseCase: Get.find(),
        removeFriendUseCase: Get.find(),
        findProfileByCodeUseCase: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
