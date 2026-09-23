part of "groups_page.dart";

// A single group's header, tab bar and the chrome around each tab.

class _GroupDetailsHeader extends StatelessWidget {
  const _GroupDetailsHeader({
    required this.group,
    required this.isLoading,
    required this.onBack,
    required this.onActions,
  });

  final GroupEntity group;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 72),
    child: Row(
      children: [
        _DetailBackButton(onTap: onBack),
        const Gap(8),
        _GroupIcon(theme: group.theme, size: 56, iconSize: 27),
        const Gap(12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedGroupName(context, group),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black28.copyWith(
                  color: context.colorTokens.textBody,
                  fontSize: 24,
                  height: 1,
                ),
              ),
              const Gap(4),
              if (isLoading)
                const AppSkeleton(
                  child: AppSkeletonBox(height: 14, width: 92, radius: 4),
                )
              else
                Text(
                  context.l10n.groupMembersCount(group.members.length),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.caption.copyWith(
                    color: context.colorTokens.primary,
                  ),
                ),
            ],
          ),
        ),
        const Gap(8),
        _DetailIconButton(
          icon: Icons.more_vert_rounded,
          semanticLabel: context.l10n.groupActionsLabel,
          onTap: onActions,
        ),
      ],
    ),
  );
}

class _GroupDetailsTabs extends StatelessWidget {
  const _GroupDetailsTabs({
    required this.selectedTab,
    required this.onSelectTab,
    required this.onSwipeTab,
  });

  final GroupDetailsTab selectedTab;
  final ValueChanged<GroupDetailsTab> onSelectTab;
  final ValueChanged<int> onSwipeTab;

  @override
  Widget build(BuildContext context) => AnimatedSegmentedTabs(
    labels: [
      context.l10n.leaderboardTitle,
      context.l10n.goalsTabLabel,
      context.l10n.chatTabLabel,
    ],
    selectedIndex: selectedTab.index,
    onSelectIndex: (index) => onSelectTab(GroupDetailsTab.values[index]),
    onSwipe: onSwipeTab,
  );
}

class _GroupDetailsTabsScope extends StatelessWidget {
  const _GroupDetailsTabsScope({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => _GroupDetailsTabs(
      selectedTab: controller.selectedDetailsTab.value,
      onSelectTab: controller.onSelectDetailsTab,
      onSwipeTab: controller.onSwipeDetailsTab,
    ),
  );
}

class _GroupDetailsContent extends StatelessWidget {
  const _GroupDetailsContent({
    required this.controller,
    required this.group,
    required this.members,
  });

  final GroupsController controller;
  final GroupEntity group;
  final List<GroupMemberEntity> members;

  @override
  Widget build(BuildContext context) => Obx(() {
    final GroupDetailsTab selectedTab = controller.selectedDetailsTab.value;
    final bool showLoadingOverlay =
        selectedTab == GroupDetailsTab.goals &&
            controller.isLoadingActivityProgress.value &&
            controller.activityHeaders.isNotEmpty ||
        selectedTab == GroupDetailsTab.chat &&
            controller.isLoadingChat.value &&
            controller.imageMessagesFor(group.id).isNotEmpty;

    return RepaintBoundary(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: IndexedStack(
                sizing: StackFit.expand,
                index: selectedTab.index,
                children: [
                  _ScrollableDetailsTab(
                    child: _RankingTab(
                      controller: controller,
                      group: group,
                      members: members,
                    ),
                  ),
                  _ScrollableDetailsTab(
                    child: _GoalsTab(controller: controller, group: group),
                  ),
                  _ChatTab(controller: controller, group: group),
                ],
              ),
            ),
            _LoadingOverlay(isVisible: showLoadingOverlay),
          ],
        ),
      ),
    );
  });
}

class _ScrollableDetailsTab extends StatelessWidget {
  const _ScrollableDetailsTab({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    child: child,
  );
}

class _TabLoadingIndicator extends StatelessWidget {
  const _TabLoadingIndicator();

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(
        strokeWidth: 2.6,
        color: context.colorTokens.primary,
      ),
    ),
  );
}

class _InlineLoadingIndicator extends StatelessWidget {
  const _InlineLoadingIndicator();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: context.colorTokens.primary,
          ),
        ),
      ],
    ),
  );
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: true,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: isVisible ? 1 : 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorTokens.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: context.colorTokens.borderUnfocused.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DetailIconButton extends StatelessWidget {
  const _DetailIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: BounceTap(
      onTap: onTap,
      pressedScale: 0.92,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppSpacing.minTapTarget,
        height: AppSpacing.minTapTarget,
        child: Icon(icon, size: 24, color: context.colorTokens.primary),
      ),
    ),
  );
}

class _DetailBackButton extends StatelessWidget {
  const _DetailBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: MaterialLocalizations.of(context).backButtonTooltip,
    child: BounceTap(
      onTap: onTap,
      pressedScale: 0.92,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppSpacing.minTapTarget,
        height: AppSpacing.minTapTarget,
        child: Center(
          child: AppIcon(
            "left_back",
            size: 20,
            color: context.colorTokens.primary,
          ),
        ),
      ),
    ),
  );
}
