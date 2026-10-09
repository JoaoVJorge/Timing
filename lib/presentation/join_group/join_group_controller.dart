import "package:timing/presentation/group_activity_links/group_activity_links_page.dart";
import "package:dartz/dartz.dart";
import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_join_outcome_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/social/social_store.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

class JoinGroupController extends GetxController {
  JoinGroupController(
    this._groupsRepository,
    this._socialStore,
    this._appNavigator,
  );

  final GroupsRepository _groupsRepository;
  final SocialStore _socialStore;
  final AppNavigator _appNavigator;

  final TextEditingController codeController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Opened from a group's link, which carries the code.
    final Object? arguments = _appNavigator.arguments;
    if (arguments is String && arguments.trim().isNotEmpty) {
      codeController.text = arguments.trim().toUpperCase();
    }
  }

  /// Asks the group's leader to let the user in. The code alone never joins a
  /// group, so the screen closes with a notice rather than with the group.
  Future<void> join() async {
    final BuildContext? context = Get.context;
    final String code = codeController.text.trim();
    if (code.isEmpty || isLoading.value || context == null) {
      return;
    }

    isLoading.value = true;
    final Either<AppError, GroupJoinOutcomeEntity> result =
        await _groupsRepository.joinGroupByInviteCode(code);
    isLoading.value = false;

    await result.fold(
      (error) async =>
          _appNavigator.showErrorOrOfflineSnackBar(context.l10n.joinGroupError),
      (outcome) async {
        final GroupEntity? group = outcome.group;
        if (group == null) {
          _appNavigator.back<GroupEntity>();
          _appNavigator.showSuccessSnackBar(
            context.l10n.groupJoinRequestSentMessage(outcome.groupName),
          );
          return;
        }
        // Already a member: the link just opens the group.
        await showGroupActivityLinks(group);
        _socialStore.announceJoinedGroup(group);
        _appNavigator.back<GroupEntity>(result: group);
      },
    );
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}
