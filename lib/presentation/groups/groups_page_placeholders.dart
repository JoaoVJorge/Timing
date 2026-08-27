part of "groups_page.dart";

// Empty, error and skeleton states for the groups home list.

class _GroupsEmptyState extends StatelessWidget {
  const _GroupsEmptyState({
    required this.onCreateGroup,
    required this.onTapFriends,
  });

  final VoidCallback onCreateGroup;
  final VoidCallback onTapFriends;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    children: [
      _FriendsCard(groupCount: 0, isLoading: false, onTap: onTapFriends),
      const Gap(AppSpacing.betweenRelated),
      AppEmptyState(
        icon: Icons.groups_2_outlined,
        title: context.l10n.groupsEmptyTitle,
        description: context.l10n.groupsEmptyDescription,
        actionLabel: context.l10n.groupsEmptyButton,
        onTapAction: onCreateGroup,
      ),
      const Gap(AppSpacing.betweenSections),
      Center(child: _BenefitsHeader(label: context.l10n.groupsBenefitsHeader)),
      const Gap(AppSpacing.betweenRelated),
      Row(
        children: [
          Expanded(
            child: _BenefitTile(
              icon: Icons.leaderboard_rounded,
              label: context.l10n.leaderboardTitle,
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
          Expanded(
            child: _BenefitTile(
              icon: Icons.show_chart_rounded,
              label: context.l10n.progressTitle,
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
          Expanded(
            child: _BenefitTile(
              icon: Icons.favorite_border_rounded,
              label: context.l10n.groupsFriendsTitle,
            ),
          ),
        ],
      ),
    ],
  );
}

class _GroupsLoadErrorState extends StatelessWidget {
  const _GroupsLoadErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    children: [
      AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: context.l10n.groupsLoadErrorTitle,
        description: context.l10n.groupsLoadErrorDescription,
        actionLabel: context.l10n.retryButton,
        onTapAction: onRetry,
      ),
    ],
  );
}

class _GroupsLoadingSkeleton extends StatelessWidget {
  const _GroupsLoadingSkeleton();

  @override
  Widget build(BuildContext context) => AppSkeleton(
    child: ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
      children: const [
        _SkeletonGroupCard(isFriends: true),
        Gap(AppSpacing.betweenRelated),
        _SkeletonGroupCard(),
        Gap(AppSpacing.betweenRelated),
        _SkeletonGroupCard(),
        Gap(AppSpacing.betweenRelated),
        _SkeletonGroupCard(),
      ],
    ),
  );
}

class _SkeletonGroupCard extends StatelessWidget {
  const _SkeletonGroupCard({this.isFriends = false});

  final bool isFriends;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: isFriends ? 78 : 124),
    padding: const EdgeInsets.all(14),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeletonCircle(
          size: isFriends ? 46 : 72,
          color: context.colorTokens.primaryVeryLight,
        ),
        const Gap(14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(width: 96, height: 18, radius: 8),
              Gap(8),
              AppSkeletonBox(height: 12, radius: 6),
              Gap(10),
              _SkeletonAvatarRow(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SkeletonAvatarRow extends StatelessWidget {
  const _SkeletonAvatarRow();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 86,
    height: 30,
    child: Stack(
      children: [
        for (int index = 0; index < 3; index++)
          Positioned(
            left: index * 20,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: context.colorTokens.surfaceInnerLayer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colorTokens.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
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
        child: Text(label, style: context.textStyles.caption),
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
    decoration: AppSurfaces.content(context.colorTokens),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 26, color: context.colorTokens.primary),
        const Gap(AppSpacing.titleToDescription),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.cardTitle.copyWith(fontSize: 14),
        ),
      ],
    ),
  );
}
