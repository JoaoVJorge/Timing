import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/presentation/groups/groups_controller.dart";
import "package:help_out/presentation/groups/widgets/current_user_rank_card.dart";
import "package:help_out/presentation/groups/widgets/group_selector.dart";
import "package:help_out/presentation/groups/widgets/leaderboard_tile.dart";
import "package:help_out/presentation/groups/widgets/period_selector.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupsController controller = Get.find();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.groupsTitle,
                      style: context.textStyles.titleFont,
                    ),
                    const Gap(4),
                    Text(
                      context.l10n.groupsSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: context.colorTokens.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              BounceTap(
                onTap: controller.onTapCreateGroup,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorTokens.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 18,
                        color: context.colorTokens.primaryForeground,
                      ),
                      const Gap(4),
                      Text(
                        context.l10n.groupHeaderCreateButton,
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colorTokens.primaryForeground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),
          Obx(
            () => GroupSelector(
              groups: controller.groups,
              selectedGroupId: controller.selectedGroup.value?.id,
              onSelectGroup: controller.onSelectGroup,
              onCreateGroup: controller.onTapCreateGroup,
            ),
          ),
          Obx(
            () => controller.groups.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      const Gap(20),
                      GroupPeriodSelector(
                        selectedPeriod: controller.selectedPeriod.value,
                        onSelectPeriod: controller.onSelectPeriod,
                      ),
                      const Gap(12),
                    ],
                  ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.groups.isEmpty) {
                return _GroupsEmptyState(
                  onCreateGroup: controller.onTapCreateGroup,
                );
              }

              final List<GroupMemberEntity> members = controller.rankedMembers;
              final GroupEntity? group = controller.selectedGroup.value;
              final GroupMemberEntity? currentUser =
                  controller.currentUserMember;

              if (members.isEmpty || group == null) {
                return Center(
                  child: Text(
                    context.l10n.noGroupSelected,
                    style: context.textStyles.bodyMedium.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                );
              }

              return ListView(
                children: [
                  Text(
                    leaderboardDescription(
                      context,
                      group.theme,
                      controller.selectedPeriod.value,
                    ),
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  if (currentUser != null) ...[
                    CurrentUserRankCard(
                      rank: controller.currentUserRank,
                      theme: group.theme,
                      value: currentUser.secondsFor(
                        controller.selectedPeriod.value,
                      ),
                      differenceToPrevious: controller.differenceToPrevious(
                        currentUser,
                      ),
                    ),
                    const Gap(20),
                  ],
                  Text(
                    context.l10n.leaderboardTitle,
                    style: context.textStyles.extraBold20,
                  ),
                  const Gap(12),
                  for (int index = 0; index < members.length; index++) ...[
                    if (index > 0) const Gap(12),
                    LeaderboardTile(
                      rank: index + 1,
                      member: members[index],
                      theme: group.theme,
                      value: members[index].secondsFor(
                        controller.selectedPeriod.value,
                      ),
                      isCurrentUser: controller.isCurrentUser(members[index]),
                      differenceToPrevious: controller.differenceToPrevious(
                        members[index],
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _GroupsEmptyState extends StatelessWidget {
  const _GroupsEmptyState({required this.onCreateGroup});

  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.groups_rounded,
          size: 48,
          color: context.colorTokens.primary,
        ),
        const Gap(16),
        Text(
          context.l10n.groupsEmptyTitle,
          style: context.textStyles.extraBold20,
        ),
        const Gap(8),
        Text(
          context.l10n.groupsEmptyDescription,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
        const Gap(20),
        BounceTap(
          onTap: onCreateGroup,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: context.colorTokens.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              context.l10n.groupsEmptyButton,
              style: context.textStyles.textPrimaryButton,
            ),
          ),
        ),
      ],
    ),
  );
}
