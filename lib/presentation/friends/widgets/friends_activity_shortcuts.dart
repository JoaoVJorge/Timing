import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

class FriendsActivityShortcuts extends StatelessWidget {
  const FriendsActivityShortcuts({
    required this.pendingCount,
    required this.sentCount,
    required this.onPendingTap,
    required this.onSentTap,
    super.key,
  });

  final int pendingCount;
  final int sentCount;
  final VoidCallback onPendingTap;
  final VoidCallback onSentTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ShortcutTile(
          icon: Icons.person_add_alt_1_rounded,
          title: context.l10n.friendRequestsReceivedTab,
          count: pendingCount,
          onTap: onPendingTap,
        ),
      ),
      const Gap(8),
      Expanded(
        child: _ShortcutTile(
          icon: Icons.send_rounded,
          title: context.l10n.friendRequestsSentTab,
          count: sentCount,
          onTap: onSentTap,
        ),
      ),
    ],
  );
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: context.colorTokens.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.colorTokens.surfaceShadow.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: context.colorTokens.primary, size: 18),
              const Gap(7),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (count > 0)
          Positioned(top: -7, right: 16, child: _ShortcutCounter(count: count)),
      ],
    ),
  );
}

class _ShortcutCounter extends StatelessWidget {
  const _ShortcutCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 20),
    height: 20,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: context.colorTokens.primaryGradient,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: context.colorTokens.scaffold, width: 1.5),
    ),
    child: Text(
      count > 99 ? "99+" : count.toString(),
      style: context.textStyles.bodySmall.copyWith(
        color: context.colorTokens.primaryForeground,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    ),
  );
}

class AddFriendHeaderButton extends StatelessWidget {
  const AddFriendHeaderButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_add_alt_1_rounded,
        color: context.colorTokens.primary,
        size: 26,
      ),
    ),
  );
}
