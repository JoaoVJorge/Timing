import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/presentation/groups/groups_controller.dart";
import "package:help_out/presentation/groups/widgets/current_user_rank_card.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
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
                            isFirst: index == 0,
                            isLast: index == members.length - 1,
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 2),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: context.colorTokens.primaryGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Gap(10),
                  _SkeletonBox(
                    width: 118,
                    height: 16,
                    radius: 8,
                    color: Colors.white.withValues(alpha: 0.36),
                  ),
                ],
              ),
            ),
            const Gap(6),
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: context.colorTokens.surface,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.add_rounded,
                color: context.colorTokens.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GroupsLoadingSkeleton extends StatelessWidget {
  const _GroupsLoadingSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 18),
    children: [
      const _CurrentUserRankSkeleton(),
      const Gap(14),
      Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: context.colorTokens.textHint,
          ),
          const Gap(6),
          const Expanded(child: _SkeletonBox(height: 12, radius: 6)),
        ],
      ),
      const Gap(16),
      const _SkeletonBox(width: 116, height: 22, radius: 10),
      const Gap(14),
      Container(
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
          ),
        ),
        child: const Column(
          children: [
            _SkeletonLeaderboardRow(
              rank: 1,
              name: "Ana",
              colorValue: 0xFFE85888,
              scoreWidth: 62,
              isFirst: true,
            ),
            Divider(height: 1, indent: 22, endIndent: 22),
            _SkeletonLeaderboardRow(
              rank: 2,
              name: "Bia",
              colorValue: 0xFF4F7DF3,
              scoreWidth: 54,
              isCurrentUser: true,
            ),
            Divider(height: 1, indent: 22, endIndent: 22),
            _SkeletonLeaderboardRow(
              rank: 3,
              name: "Leo",
              colorValue: 0xFF42B976,
              scoreWidth: 48,
              isLast: true,
            ),
          ],
        ),
      ),
    ],
  );
}

class _CurrentUserRankSkeleton extends StatelessWidget {
  const _CurrentUserRankSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 30,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(14),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _SkeletonBox(width: 86, height: 12, radius: 6),
                  Gap(8),
                  _SkeletonBox(width: 64, height: 24, radius: 10),
                ],
              ),
            ),
            const Gap(8),
          ],
        ),
        const Gap(14),
        Divider(height: 1, color: context.colorTokens.divider),
        const Gap(14),
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 22,
              color: context.colorTokens.primary,
            ),
            const _SkeletonBox(width: 76, height: 24, radius: 10),
          ],
        ),
        const Gap(8),
        const _SkeletonBox(width: 160, height: 12, radius: 6),
      ],
    ),
  );
}

class _SkeletonLeaderboardRow extends StatelessWidget {
  const _SkeletonLeaderboardRow({
    required this.rank,
    required this.name,
    required this.colorValue,
    required this.scoreWidth,
    this.isCurrentUser = false,
    this.isFirst = false,
    this.isLast = false,
  });

  final int rank;
  final String name;
  final int colorValue;
  final double scoreWidth;
  final bool isCurrentUser;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final BorderRadius userRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(18) : Radius.zero,
      bottom: isLast ? const Radius.circular(18) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.transparent,
        borderRadius: isCurrentUser ? userRadius : BorderRadius.zero,
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: context.colorTokens.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Center(
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 32,
                color: _SkeletonMedalColors.byRank(rank),
              ),
            ),
          ),
          const Gap(6),
          GroupMemberAvatar(name: name, colorValue: colorValue, size: 50),
          const Gap(14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 118, height: 16, radius: 8),
                Gap(8),
                _SkeletonBox(width: 94, height: 11, radius: 6),
              ],
            ),
          ),
          const Gap(10),
          _SkeletonBox(width: scoreWidth, height: 16, radius: 8),
        ],
      ),
    );
  }
}

class _SkeletonMedalColors {
  static Color byRank(int rank) => switch (rank) {
    1 => const Color(0xFFE4B13B),
    2 => const Color(0xFF9AA3AD),
    3 => const Color(0xFFC98549),
    _ => const Color(0xFF9AA3AD),
  };
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    this.width,
    this.radius = 14,
    this.color,
  });

  final double height;
  final double? width;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveColor =
        color ??
        (isDarkMode ? const Color(0xFF343434) : const Color(0xFFE5E5E5));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveColor,
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
