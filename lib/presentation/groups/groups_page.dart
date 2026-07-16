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
          const Gap(18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.groupsTitle,
                style: context.textStyles.black32.copyWith(fontSize: 34),
              ),
              const Gap(4),
              Text(
                context.l10n.groupsSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge.copyWith(
                  color: context.colorTokens.textHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(6),
          Obx(
            () => GroupSelector(
              groups: controller.groups,
              selectedGroupId: controller.selectedGroup.value?.id,
              onSelectGroup: controller.onSelectGroup,
              onCreateGroup: controller.onTapCreateGroup,
            ),
          ),
          const Gap(6),
          Obx(
            () => controller.groups.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      GroupPeriodSelector(
                        selectedPeriod: controller.selectedPeriod.value,
                        onSelectPeriod: controller.onSelectPeriod,
                      ),
                      const Gap(18),
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
                padding: const EdgeInsets.only(bottom: 18),
                children: [
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
                    const Gap(14),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: context.colorTokens.primary.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      const Gap(6),
                      Expanded(
                        child: Text(
                          leaderboardDescription(
                            context,
                            group.theme,
                            controller.selectedPeriod.value,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colorTokens.textHint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Text(
                    context.l10n.leaderboardTitle,
                    style: context.textStyles.extraBold24.copyWith(
                      color: context.colorTokens.textBody.withValues(
                        alpha: 0.94,
                      ),
                      fontSize: 22,
                    ),
                  ),
                  const Gap(14),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colorTokens.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorTokens.surfaceShadow.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: context.colorTokens.borderUnfocused.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (
                          int index = 0;
                          index < members.length;
                          index++
                        ) ...[
                          LeaderboardTile(
                            rank: index + 1,
                            member: members[index],
                            theme: group.theme,
                            value: members[index].secondsFor(
                              controller.selectedPeriod.value,
                            ),
                            isCurrentUser: controller.isCurrentUser(
                              members[index],
                            ),
                            differenceToPrevious: controller
                                .differenceToPrevious(members[index]),
                          ),
                          if (index < members.length - 1)
                            Divider(
                              height: 1,
                              indent: 22,
                              endIndent: 22,
                              color: context.colorTokens.divider,
                            ),
                        ],
                      ],
                    ),
                  ),
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
          size: 46,
          color: context.colorTokens.primary,
        ),
        const Gap(14),
        Text(
          context.l10n.groupsEmptyTitle,
          style: context.textStyles.extraBold20.copyWith(fontSize: 18),
        ),
        const Gap(6),
        Text(
          context.l10n.groupsEmptyDescription,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textHint,
            fontSize: 12,
          ),
        ),
        const Gap(18),
        BounceTap(
          onTap: onCreateGroup,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: context.colorTokens.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              context.l10n.groupsEmptyButton,
              style: context.textStyles.textPrimaryButton.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
