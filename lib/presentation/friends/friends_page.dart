import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_ui_constants.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/friends/friends_controller.dart";
import "package:help_out/presentation/friends/widgets/friends_activity_shortcuts.dart";
import "package:help_out/presentation/friends/widgets/friends_invite_code_disclosure.dart";
import "package:help_out/presentation/friends/widgets/friends_loading_skeleton.dart";
import "package:help_out/presentation/friends/widgets/friends_section.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";

class FriendsPage extends GetView<FriendsController> {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: context.colorTokens.scaffold,
    padding: EdgeInsets.zero,
    topBar: AppTopBar(
      title: _friendsTitle(context),
      showBackButton: true,
      onBack: () => appNavigator.back<void>(id: 1),
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
                    onPendingTap: controller.openPendingRequestsPage,
                    onSentTap: controller.openSentRequestsPage,
                  ),
                  const Gap(18),
                  FriendsSection(
                    friends: controller.friends,
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

  String _friendsTitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Amigos",
    "pt" => "Amigos",
    _ => "Friends",
  };
}
