import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/friends/widgets/friends_shared.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

import "package:timing/theme/app_spacing.dart";

class FriendsRequestLayout<T> extends StatelessWidget {
  const FriendsRequestLayout({
    required this.title,
    required this.selectedMode,
    required this.incomingMode,
    required this.sentMode,
    required this.onSelect,
    required this.child,
    super.key,
  });

  final String title;
  final T selectedMode;
  final T incomingMode;
  final T sentMode;
  final ValueChanged<T> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: title,
      showBackButton: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequestsModeTabs<T>(
          selectedMode: selectedMode,
          incomingMode: incomingMode,
          sentMode: sentMode,
          onSelect: onSelect,
        ),
        const Gap(18),
        Expanded(child: child),
        const Gap(18),
      ],
    ),
  );
}

class FriendsRequestCard extends StatelessWidget {
  const FriendsRequestCard({
    required this.child,
    this.padding = AppSpacing.tile,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: friendsSurfaceDecoration(context, radius: 18),
    child: child,
  );
}

class FriendsRequestActions extends StatelessWidget {
  const FriendsRequestActions({
    required this.isAccepting,
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: FriendRequestActionButton(
          label: context.l10n.declineButton,
          isPrimary: false,
          isEnabled: !isAccepting,
          onTap: onDecline,
        ),
      ),
      const Gap(10),
      Expanded(
        child: FriendRequestActionButton(
          label: context.l10n.acceptButton,
          isPrimary: true,
          isLoading: isAccepting,
          onTap: onAccept,
        ),
      ),
    ],
  );
}

class _RequestsModeTabs<T> extends StatelessWidget {
  const _RequestsModeTabs({
    required this.selectedMode,
    required this.onSelect,
    required this.incomingMode,
    required this.sentMode,
  });

  final T selectedMode;
  final T incomingMode;
  final T sentMode;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _RequestModeTab(
          icon: Icons.inbox_rounded,
          label: context.l10n.receivedTab,
          isSelected: selectedMode == incomingMode,
          onTap: () => onSelect(incomingMode),
        ),
      ),
      const Gap(10),
      Expanded(
        child: _RequestModeTab(
          icon: Icons.send_rounded,
          label: context.l10n.sentLabel,
          isSelected: selectedMode == sentMode,
          onTap: () => onSelect(sentMode),
        ),
      ),
    ],
  );
}

class _RequestModeTab extends StatelessWidget {
  const _RequestModeTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    child: Container(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isSelected ? context.colorTokens.primaryGradient : null,
        color: isSelected ? null : context.colorTokens.surfaceInnerLayer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? context.colorTokens.primaryForeground
                : context.colorTokens.textHint,
          ),
          const Gap(7),
          Text(
            label,
            style: context.textStyles.bodySmall.copyWith(
              color: isSelected
                  ? context.colorTokens.primaryForeground
                  : context.colorTokens.textHint,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class FriendsRequestEmptyState extends StatelessWidget {
  const FriendsRequestEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
      decoration: friendsSurfaceDecoration(context, radius: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FriendsPinkBadge(icon: icon, size: 64, iconSize: 34),
          const Gap(14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.extraBold20.copyWith(fontSize: 17),
          ),
          const Gap(6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
