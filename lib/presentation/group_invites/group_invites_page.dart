import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_ui_constants.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/group_invites/group_invites_controller.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/shared/widgets/app_empty_state.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

class GroupInvitesPage extends GetView<GroupInvitesController> {
  const GroupInvitesPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: context.colorTokens.scaffold,
    padding: EdgeInsets.zero,
    topBar: AppTopBar(
      title: context.l10n.inviteMembersTitle,
      showBackButton: true,
      onBack: () => appNavigator.back<void>(),
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: context.colorTokens.primary),
        );
      }

      if (controller.options.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppUiConstants.pagePadding,
          ),
          child: AppEmptyState(
            icon: Icons.person_add_alt_1_rounded,
            title: context.l10n.groupInvitesNoFriendsTitle,
            description: context.l10n.groupInvitesNoFriendsDescription,
          ),
        );
      }

      return RefreshIndicator(
        color: context.colorTokens.primary,
        onRefresh: controller.loadOptions,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppUiConstants.pagePadding,
            0,
            AppUiConstants.pagePadding,
            20,
          ),
          itemCount: controller.options.length,
          separatorBuilder: (_, _) => const Gap(10),
          itemBuilder: (context, index) => _GroupInviteRow(
            option: controller.options[index],
            isUpdating: controller.updatingFriendIds.contains(
              controller.options[index].friendId,
            ),
            onTap: () => controller.onTapOption(controller.options[index]),
          ),
        ),
      );
    }),
  );
}

class _GroupInviteRow extends StatelessWidget {
  const _GroupInviteRow({
    required this.option,
    required this.isUpdating,
    required this.onTap,
  });

  final GroupInviteOptionEntity option;
  final bool isUpdating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _InviteVisuals visuals = _visualsFor(context, option.status);
    final bool canTap = !option.isMember && !isUpdating;

    return IgnorePointer(
      ignoring: !canTap,
      child: BounceTap(
        onTap: onTap,
        pressedScale: 0.98,
        child: Container(
          constraints: const BoxConstraints(minHeight: 74),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.colorTokens.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.colorTokens.borderUnfocused.withValues(
                alpha: 0.48,
              ),
            ),
          ),
          child: Row(
            children: [
              GroupMemberAvatar(
                name: option.friendName,
                colorValue: option.accentColorValue,
                avatar: "",
                size: 46,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.friendName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(6),
                    _InviteStatusBadge(visuals: visuals),
                  ],
                ),
              ),
              const Gap(10),
              SizedBox.square(
                dimension: 38,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: visuals.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isUpdating
                        ? SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: visuals.color,
                            ),
                          )
                        : Icon(visuals.icon, color: visuals.color, size: 21),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _InviteVisuals _visualsFor(BuildContext context, GroupInviteStatus status) =>
      switch (status) {
        GroupInviteStatus.invited => _InviteVisuals(
          label: context.l10n.invitedLabel,
          icon: Icons.mark_email_read_outlined,
          color: context.colorTokens.primary,
        ),
        GroupInviteStatus.member => _InviteVisuals(
          label: context.l10n.groupMemberRoleLabel,
          icon: Icons.verified_rounded,
          color: context.colorTokens.success,
        ),
        GroupInviteStatus.available => _InviteVisuals(
          label: context.l10n.selectButton,
          icon: Icons.add_rounded,
          color: context.colorTokens.textBody,
        ),
      };
}

class _InviteStatusBadge extends StatelessWidget {
  const _InviteStatusBadge({required this.visuals});

  final _InviteVisuals visuals;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: visuals.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      visuals.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.bodySmall.copyWith(
        color: visuals.color,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _InviteVisuals {
  const _InviteVisuals({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
