import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_ui_constants.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/friends/friends_controller.dart";
import "package:timing/presentation/friends/widgets/friends_activity_shortcuts.dart";
import "package:timing/presentation/friends/widgets/friends_invite_code_disclosure.dart";
import "package:timing/presentation/friends/widgets/friends_loading_skeleton.dart";
import "package:timing/presentation/friends/widgets/friends_section.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";

class FriendsPage extends GetView<FriendsController> {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: context.colorTokens.scaffold,
    padding: EdgeInsets.zero,
    topBar: AppTopBar(
      title: context.l10n.friendsTitle,
      showBackButton: true,
      onBack: () => appNavigator.back<void>(),
      trailing: AddFriendHeaderButton(onTap: controller.openAddFriendPage),
    ),
    body: RefreshIndicator(
      color: context.colorTokens.primary,
      onRefresh: controller.loadSocial,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppUiConstants.pagePadding,
          0,
          AppUiConstants.pagePadding,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => FriendsInviteCodeDisclosure(
                code: controller.inviteCode.value.isEmpty
                    ? "..."
                    : controller.inviteCode.value,
                onCopy: controller.copyInviteCode,
                onShare: controller.shareInviteCode,
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const FriendsLoadingSkeleton();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(14),
                  FriendsActivityShortcuts(
                    pendingCount: controller.requests.length,
                    sentCount:
                        controller.groupInvitations.length +
                        controller.sentGroupInvitations.length,
                    onPendingTap: controller.openPendingRequestsPage,
                    onSentTap: controller.openGroupInvitationsPage,
                  ),
                  const Gap(18),
                  FriendsSection(
                    friends: controller.friends.toList(),
                    now: controller.presenceNow.value,
                    onShare: controller.shareInviteCode,
                    onRemove: controller.removeFriend,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    ),
  );
}
