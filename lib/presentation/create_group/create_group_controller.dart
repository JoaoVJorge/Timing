import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/create_group_use_case.dart";
import "package:help_out/core/domain/use_cases/get_invitable_friends_use_case.dart";

class CreateGroupController extends GetxController {
  CreateGroupController({
    required this._getInvitableFriendsUseCase,
    required this._createGroupUseCase,
    required this._appNavigator,
  });

  final GetInvitableFriendsUseCase _getInvitableFriendsUseCase;
  final CreateGroupUseCase _createGroupUseCase;
  final AppNavigator _appNavigator;

  final TextEditingController groupNameController = TextEditingController();
  final RxList<FriendOption> availableFriends = <FriendOption>[].obs;
  final RxSet<String> selectedFriendIds = <String>{}.obs;
  final Rx<GroupThemeType?> selectedTheme = Rx<GroupThemeType?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isCreating = false.obs;
  final RxBool canCreate = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFriends();
  }

  Future<void> loadFriends() async {
    isLoading.value = true;
    final Either<AppError, List<FriendOption>> result =
        await _getInvitableFriendsUseCase();
    result.fold(
      (error) => availableFriends.clear(),
      (friends) => availableFriends.value = friends,
    );
    isLoading.value = false;
  }

  void onGroupNameChanged(String value) => _refreshCanCreate();

  void onSelectTheme(GroupThemeType theme) {
    selectedTheme.value = theme;
    _refreshCanCreate();
  }

  void _refreshCanCreate() => canCreate.value =
      groupNameController.text.trim().isNotEmpty && selectedTheme.value != null;

  void onToggleFriend(String friendId) {
    if (selectedFriendIds.contains(friendId)) {
      selectedFriendIds.remove(friendId);
    } else {
      selectedFriendIds.add(friendId);
    }
  }

  Future<void> onTapCreate() async {
    final String name = groupNameController.text.trim();
    final GroupThemeType? theme = selectedTheme.value;
    if (name.isEmpty || theme == null) {
      return;
    }

    isCreating.value = true;
    final List<FriendOption> invitedFriends = availableFriends
        .where((friend) => selectedFriendIds.contains(friend.id))
        .toList();
    final Either<AppError, GroupEntity> result = await _createGroupUseCase(
      name: name,
      theme: theme,
      invitedFriends: invitedFriends,
    );
    isCreating.value = false;

    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (group) => _appNavigator.back<GroupEntity>(result: group),
    );
  }

  @override
  void onClose() {
    groupNameController.dispose();
    super.onClose();
  }
}
