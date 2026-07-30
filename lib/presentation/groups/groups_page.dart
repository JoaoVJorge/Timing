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
          Obx(() {
            if (controller.isLoading.value && controller.groups.isEmpty) {
              return const _GroupSelectorSkeleton();
            }

            if (controller.groups.isEmpty) {
              return const Gap(24);
            }

            return Column(
              children: [
                const Gap(6),
                GroupSelector(
                  groups: controller.groups,
                  selectedGroupId: controller.selectedGroup.value?.id,
                  onSelectGroup: controller.onSelectGroup,
                  onCreateGroup: controller.onTapCreateGroup,
                ),
              ],
            );
          }),
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
              if (controller.isLoading.value && controller.groups.isEmpty) {
                return const _GroupsLoadingSkeleton();
              }

              if (controller.groups.isEmpty) {
                return _GroupsEmptyState(
                  onCreateGroup: controller.onTapCreateGroup,
                  onJoinWithCode: controller.onTapJoinWithCode,
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
                        color: context.colorTokens.textHint,
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
  const _GroupsEmptyState({
    required this.onCreateGroup,
    required this.onJoinWithCode,
  });

  final VoidCallback onCreateGroup;
  final VoidCallback onJoinWithCode;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 14),
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.70),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorTokens.primaryVeryLight,
              ),
              child: Icon(
                Icons.groups_2_outlined,
                size: 46,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(16),
            Text(
              context.l10n.groupsEmptyTitle,
              textAlign: TextAlign.center,
              style: context.textStyles.extraBold24.copyWith(
                color: context.colorTokens.textBody,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Gap(8),
            Text(
              context.l10n.groupsEmptyDescription,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.textHint,
                fontSize: 13,
                height: 1.28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(16),
            _EmptyPrimaryButton(
              label: context.l10n.groupsEmptyButton,
              onTap: onCreateGroup,
            ),
            const Gap(10),
            _EmptySecondaryButton(
              label: _joinWithCodeLabel(context),
              onTap: onJoinWithCode,
            ),
          ],
        ),
      ),
      const Gap(22),
      Center(child: _BenefitsHeader(label: _benefitsHeader(context))),
      const Gap(12),
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 96,
              child: _BenefitTile(
                icon: Icons.leaderboard_rounded,
                label: _rankingLabel(context),
              ),
            ),
            const Gap(10),
            SizedBox(
              width: 96,
              child: _BenefitTile(
                icon: Icons.show_chart_rounded,
                label: _progressLabel(context),
              ),
            ),
            const Gap(10),
            SizedBox(
              width: 96,
              child: _BenefitTile(
                icon: Icons.favorite_border_rounded,
                label: _friendsLabel(context),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  String _joinWithCodeLabel(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Tengo un código de invitación",
        "pt" => "Tenho um código de convite",
        _ => "I have an invite code",
      };

  String _benefitsHeader(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "En un grupo puedes:",
        "pt" => "Em um grupo você pode:",
        _ => "In a group you can:",
      };

  String _rankingLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Ranking",
    "pt" => "Ranking",
    _ => "Ranking",
  };

  String _progressLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Progreso",
    "pt" => "Progresso",
    _ => "Progress",
  };

  String _friendsLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Amigos",
    "pt" => "Amigos",
    _ => "Friends",
  };
}

class _EmptyPrimaryButton extends StatelessWidget {
  const _EmptyPrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.97,
    child: Container(
      width: double.infinity,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.textPrimaryButton.copyWith(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _GroupSelectorSkeleton extends StatelessWidget {
  const _GroupSelectorSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 6, bottom: 2),
    child: Row(
      children: [
        Expanded(child: _SkeletonBox(height: 54, radius: 18)),
        Gap(10),
        _SkeletonBox(width: 54, height: 54, radius: 18),
      ],
    ),
  );
}

class _GroupsLoadingSkeleton extends StatelessWidget {
  const _GroupsLoadingSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 18),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
          ),
        ),
        child: const Row(
          children: [
            _SkeletonBox(width: 54, height: 54, radius: 27),
            Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 130, height: 16, radius: 8),
                  Gap(10),
                  _SkeletonBox(width: 190, height: 12, radius: 6),
                ],
              ),
            ),
            _SkeletonBox(width: 48, height: 30, radius: 12),
          ],
        ),
      ),
      const Gap(14),
      const Row(
        children: [
          _SkeletonBox(width: 18, height: 18, radius: 9),
          Gap(8),
          Expanded(child: _SkeletonBox(height: 12, radius: 6)),
        ],
      ),
      const Gap(18),
      const _SkeletonBox(width: 150, height: 22, radius: 10),
      const Gap(14),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
          ),
        ),
        child: const Column(
          children: [
            _SkeletonLeaderboardRow(),
            _SkeletonLeaderboardRow(),
            _SkeletonLeaderboardRow(),
            _SkeletonLeaderboardRow(),
          ],
        ),
      ),
    ],
  );
}

class _SkeletonLeaderboardRow extends StatelessWidget {
  const _SkeletonLeaderboardRow();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    child: Row(
      children: const [
        _SkeletonBox(width: 28, height: 20, radius: 8),
        Gap(12),
        _SkeletonBox(width: 42, height: 42, radius: 21),
        Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(width: 118, height: 14, radius: 7),
              Gap(8),
              _SkeletonBox(width: 78, height: 10, radius: 5),
            ],
          ),
        ),
        _SkeletonBox(width: 58, height: 16, radius: 8),
      ],
    ),
  );
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.width, this.radius = 14});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color color = isDarkMode
        ? context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.74)
        : context.colorTokens.primaryVeryLight.withValues(alpha: 0.64);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _EmptySecondaryButton extends StatelessWidget {
  const _EmptySecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.97,
    child: Container(
      width: double.infinity,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.95),
          width: 1.4,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyLarge.copyWith(
          color: context.colorTokens.textBody,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _BenefitsHeader extends StatelessWidget {
  const _BenefitsHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _HeaderLine(color: context.colorTokens.borderUnfocused),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          label,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textHint,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      _HeaderLine(color: context.colorTokens.borderUnfocused),
    ],
  );
}

class _HeaderLine extends StatelessWidget {
  const _HeaderLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 22, height: 1.2, color: color);
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 88,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.70),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: context.colorTokens.primary),
        const Gap(8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyLarge.copyWith(
            color: context.colorTokens.textBody,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
