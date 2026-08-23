import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/presentation/friends/friends_controller.dart";
import "package:timing/shared/widgets/app_confirmation_dialog.dart";

class GroupInvitesController extends GetxController {
  GroupInvitesController({
    required this.groupsRepository,
    required this.appNavigator,
  });

  final GroupsRepository groupsRepository;
  final AppNavigator appNavigator;

  final RxList<GroupInviteOptionEntity> options =
      <GroupInviteOptionEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxSet<String> updatingFriendIds = <String>{}.obs;

  late final GroupEntity group;

  @override
  void onInit() {
    super.onInit();
    final Object? arguments = appNavigator.arguments;
    if (arguments is GroupEntity) {
      group = arguments;
      loadOptions();
      return;
    }
    group = const GroupEntity(
      id: "",
      name: "",
      theme: GroupThemeType.studying,
      members: [],
    );
    isLoading.value = false;
  }

  Future<void> loadOptions({bool showLoading = true}) async {
    if (group.id.isEmpty) {
      return;
    }
    if (showLoading) {
      isLoading.value = true;
    }
    final Either<AppError, List<GroupInviteOptionEntity>> result =
        await groupsRepository.getGroupInviteOptions(group.id);
    result.fold(
      (_) => appNavigator.showErrorSnackBar(),
      (value) => options.assignAll(value),
    );
    if (showLoading) {
      isLoading.value = false;
    }
  }

  Future<void> onTapOption(GroupInviteOptionEntity option) async {
    if (option.isMember || updatingFriendIds.contains(option.friendId)) {
      return;
    }

    final BuildContext? context = Get.context;
    if (context == null) {
      return;
    }

    final bool confirmed = await _confirm(
      title: option.isInvited ? "Cancelar convite?" : "Convidar amigo?",
      content: option.isInvited
          ? "Deseja cancelar o convite enviado para ${option.friendName}?"
          : "Deseja convidar ${option.friendName} para ${group.name}?",
      confirmLabel: option.isInvited ? "Cancelar convite" : "Convidar",
      isDestructive: option.isInvited,
    );
    if (!confirmed) {
      return;
    }

    updatingFriendIds.add(option.friendId);
    final Either<AppError, void> result = option.isInvited
        ? await groupsRepository.cancelGroupInvitation(
            groupId: group.id,
            friendId: option.friendId,
          )
        : await groupsRepository.inviteFriendToGroup(
            groupId: group.id,
            friendId: option.friendId,
          );
    updatingFriendIds.remove(option.friendId);

    await result.fold((_) async => appNavigator.showErrorSnackBar(), (_) async {
      _updateOptionState(
        option,
        option.isInvited
            ? GroupInviteStatus.available
            : GroupInviteStatus.invited,
      );
      appNavigator.showSuccessSnackBar(
        option.isInvited ? "Convite cancelado." : "Convite enviado.",
      );

      await Future.wait([
        loadOptions(showLoading: false),
        if (Get.isRegistered<FriendsController>())
          Get.find<FriendsController>().refreshGroupInvitations(),
      ]);
    });
  }

  void _updateOptionState(
    GroupInviteOptionEntity option,
    GroupInviteStatus status,
  ) {
    final int index = options.indexWhere(
      (item) => item.friendId == option.friendId,
    );
    if (index < 0) {
      return;
    }
    options[index] = option.copyWith(
      status: status,
      clearInvitationId: status == GroupInviteStatus.available,
    );
  }

  Future<bool> _confirm({
    required String title,
    required String content,
    required String confirmLabel,
    required bool isDestructive,
  }) async {
    return showAppConfirmationDialog(
      title: title,
      message: content,
      confirmLabel: confirmLabel,
      icon: isDestructive
          ? Icons.mail_outline_rounded
          : Icons.person_add_alt_1_rounded,
      isDestructive: isDestructive,
    );
  }
}
