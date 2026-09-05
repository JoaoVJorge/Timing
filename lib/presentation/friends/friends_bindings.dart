import "package:get/get.dart";
import "package:timing/presentation/friends/friends_controller.dart";

class FriendsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<FriendsController>(
      FriendsController(
        getFriendsSocialUseCase: Get.find(),
        getFriendPresencesUseCase: Get.find(),
        appController: Get.find(),
        sendFriendRequestUseCase: Get.find(),
        acceptFriendRequestUseCase: Get.find(),
        declineFriendRequestUseCase: Get.find(),
        cancelFriendRequestUseCase: Get.find(),
        removeFriendUseCase: Get.find(),
        findProfileByCodeUseCase: Get.find(),
        getGroupInvitationsUseCase: Get.find(),
        acceptGroupInvitationUseCase: Get.find(),
        declineGroupInvitationUseCase: Get.find(),
        groupsRepository: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
