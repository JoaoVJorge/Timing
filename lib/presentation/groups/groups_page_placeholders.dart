part of "groups_page.dart";

// Empty, error and skeleton states for the groups home list.

class _GroupsOfflineState extends StatelessWidget {
  const _GroupsOfflineState();

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.betweenSections),
      child: AppEmptyState(
        icon: Icons.wifi_off_rounded,
        title: context.l10n.groupsOfflineTitle,
        description: context.l10n.groupsOfflineDescription,
      ),
    ),
  );
}

class _GroupsOfflineCachedNotice extends StatelessWidget {
  const _GroupsOfflineCachedNotice();

  @override
  Widget build(BuildContext context) => _GroupsNotice(
    icon: Icons.wifi_off_rounded,
    message: context.l10n.groupsOfflineCachedNotice,
    tone: _GroupsNoticeTone.info,
  );
}

class _GroupsStaleNotice extends StatelessWidget {
  const _GroupsStaleNotice({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _GroupsNotice(
    icon: Icons.cloud_off_rounded,
    message: context.l10n.groupsStaleNotice,
    tone: _GroupsNoticeTone.warning,
    actionLabel: context.l10n.retryButton,
    onAction: onRetry,
  );
}

enum _GroupsNoticeTone { info, warning }

class _GroupsNotice extends StatelessWidget {
  const _GroupsNotice({
    required this.icon,
    required this.message,
    required this.tone,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final _GroupsNoticeTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final Color accent = switch (tone) {
      _GroupsNoticeTone.info => context.colorTokens.info,
      _GroupsNoticeTone.warning => context.colorTokens.warning,
    };
    final bool hasAction = actionLabel != null && onAction != null;

    return Container(
      key: ValueKey<String>("groups-notice-${tone.name}"),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.10
                : 0.06,
          ),
          context.colorTokens.surface,
        ),
        borderRadius: BorderRadius.circular(AppSurfaces.groupRadius),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const Gap(AppSpacing.betweenRelated),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (hasAction) ...[
                  const Gap(10),
                  TextButton.icon(
                    key: const ValueKey<String>("groups-notice-retry"),
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                      backgroundColor: accent.withValues(alpha: 0.10),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: context.textStyles.caption.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsEmptyState extends StatelessWidget {
  const _GroupsEmptyState({
    required this.friends,
    required this.pendingCount,
    required this.isLoadingFriends,
    required this.onCreateGroup,
    required this.onTapFriends,
  });

  final List<FriendEntity> friends;
  final int pendingCount;
  final bool isLoadingFriends;
  final VoidCallback onCreateGroup;
  final VoidCallback onTapFriends;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    children: [
      _FriendsCard(
        groupCount: 0,
        friends: friends,
        pendingCount: pendingCount,
        isLoading: isLoadingFriends,
        onTap: onTapFriends,
      ),
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
      // Each benefit is a second way into the same creation flow: whoever
      // taps one is asking for the group that would give it to them.
      Row(
        children: [
          Expanded(
            child: _BenefitTile(
              icon: Icons.leaderboard_rounded,
              label: context.l10n.leaderboardTitle,
              onTap: onCreateGroup,
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
          Expanded(
            child: _BenefitTile(
              icon: Icons.show_chart_rounded,
              label: context.l10n.progressTitle,
              onTap: onCreateGroup,
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
          Expanded(
            child: _BenefitTile(
              icon: Icons.favorite_border_rounded,
              label: context.l10n.groupsFriendsTitle,
              onTap: onCreateGroup,
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
        _SkeletonFriendsCard(),
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

/// Stands in for [_FriendsCard]: the icon, the title and the row of friends,
/// with the same metrics so the card does not change height once loaded.
class _SkeletonFriendsCard extends StatelessWidget {
  const _SkeletonFriendsCard();

  @override
  Widget build(BuildContext context) {
    // The title is real text once loaded, so its bar is one line of it tall.
    final TextStyle titleStyle = context.textStyles.cardTitle;
    final double titleLineHeight = titleStyle.fontSize! * titleStyle.height!;

    return Container(
      key: const ValueKey<String>("friends-card-skeleton"),
      constraints: const BoxConstraints(minHeight: 78),
      padding: AppSpacing.tile,
      decoration: AppSurfaces.content(context.colorTokens),
      child: Row(
        children: [
          AppSkeletonCircle(
            size: 46,
            color: context.colorTokens.primaryVeryLight,
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSkeletonBox(
                  key: const ValueKey<String>("friends-card-skeleton-title"),
                  width: 72,
                  height: titleLineHeight,
                  radius: 8,
                ),
                const Gap(8),
                const _SkeletonAvatarRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonGroupCard extends StatelessWidget {
  const _SkeletonGroupCard();

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 124),
    padding: AppSpacing.tile,
    decoration: AppSurfaces.content(context.colorTokens),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeletonCircle(
          size: 72,
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
  const _BenefitTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    behavior: HitTestBehavior.opaque,
    child: Container(
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
    ),
  );
}
