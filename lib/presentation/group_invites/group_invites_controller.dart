import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";

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

  Future<void> loadOptions() async {
    if (group.id.isEmpty) {
      return;
    }
    isLoading.value = true;
    final Either<AppError, List<GroupInviteOptionEntity>> result =
        await groupsRepository.getGroupInviteOptions(group.id);
    result.fold(
      (_) => appNavigator.showErrorSnackBar(),
      (value) => options.assignAll(value),
    );
    isLoading.value = false;
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

    result.fold((_) => appNavigator.showErrorSnackBar(), (_) {
      appNavigator.showSuccessSnackBar(
        option.isInvited ? "Convite cancelado." : "Convite enviado.",
      );
      loadOptions();
    });
  }

  Future<bool> _confirm({
    required String title,
    required String content,
    required String confirmLabel,
    required bool isDestructive,
  }) async {
    final bool? confirmed = await appNavigator.dialog<bool>(
      child: AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => appNavigator.back<bool>(result: false),
            child: const Text("Voltar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isDestructive
                  ? Get.context?.theme.colorScheme.error
                  : null,
            ),
            onPressed: () => appNavigator.back<bool>(result: true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
