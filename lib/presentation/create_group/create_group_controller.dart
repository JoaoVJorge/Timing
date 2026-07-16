import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
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
  final TextEditingController friendSearchController = TextEditingController();
  final RxList<FriendOption> availableFriends = <FriendOption>[].obs;
  final RxSet<String> selectedFriendIds = <String>{}.obs;
  final Rx<GroupThemeType?> selectedTheme = Rx<GroupThemeType?>(null);
  final RxString groupName = "".obs;
  final RxString friendSearchQuery = "".obs;
  final RxBool isLoading = true.obs;
  final RxBool hasLoadError = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool canCreate = false.obs;

  bool get hasName => groupName.value.trim().isNotEmpty;

  bool get hasTheme => selectedTheme.value != null;

  bool get hasFriends => selectedFriendIds.isNotEmpty;

  List<FriendOption> get filteredFriends {
    final String query = friendSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return availableFriends;
    }
    return availableFriends
        .where((friend) => friend.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    groupNameController.addListener(_syncGroupName);
    loadFriends();
  }

  Future<void> loadFriends() async {
    isLoading.value = true;
    hasLoadError.value = false;
    final Either<AppError, List<FriendOption>> result =
        await _getInvitableFriendsUseCase();
    result.fold((error) {
      availableFriends.clear();
      hasLoadError.value = true;
    }, (friends) => availableFriends.value = friends);
    isLoading.value = false;
  }

  void onGroupNameChanged(String value) {
    if (groupName.value != value) {
      groupName.value = value;
    }
    _refreshCanCreate();
  }

  void _syncGroupName() {
    final String value = groupNameController.text;
    if (groupName.value == value) {
      return;
    }
    groupName.value = value;
    _refreshCanCreate();
  }

  void onFriendSearchChanged(String value) => friendSearchQuery.value = value;

  void onSelectTheme(GroupThemeType theme) {
    selectedTheme.value = theme;
    _refreshCanCreate();
  }

  void _refreshCanCreate() =>
      canCreate.value = hasName && hasTheme && hasFriends;

  String createButtonText(BuildContext context) {
    if (!hasName) {
      return context.l10n.createGroupMissingName;
    }
    if (!hasTheme) {
      return context.l10n.createGroupMissingTheme;
    }
    if (!hasFriends) {
      return context.l10n.createGroupMissingFriends;
    }
    final int count = selectedFriendIds.length;
    return context.l10n.createGroupWithFriendsButton(count);
  }

  void onToggleFriend(String friendId) {
    if (selectedFriendIds.contains(friendId)) {
      selectedFriendIds.remove(friendId);
    } else {
      selectedFriendIds.add(friendId);
    }
    _refreshCanCreate();
  }

  Future<void> onTapCreate() async {
    if (isCreating.value) {
      return;
    }

    final String name = groupNameController.text.trim();
    final GroupThemeType? theme = selectedTheme.value;
    if (name.isEmpty) {
      _appNavigator.showErrorSnackBar(Get.context!.l10n.nameRequiredError);
      return;
    }
    if (theme == null) {
      _appNavigator.showErrorSnackBar(
        Get.context!.l10n.groupThemeRequiredError,
      );
      return;
    }
    if (selectedFriendIds.isEmpty) {
      _appNavigator.showErrorSnackBar(Get.context!.l10n.groupNeedsFriendError);
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
    groupNameController.removeListener(_syncGroupName);
    groupNameController.dispose();
    friendSearchController.dispose();
    super.onClose();
  }
}
