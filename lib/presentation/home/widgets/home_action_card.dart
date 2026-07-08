import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// Hero card at the top of Home carrying the single next best action:
/// resume a subject, start the suggested one, or create the first subject.
class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    required this.eyebrow,
    required this.title,
    required this.actionIcon,
    required this.onTap,
    this.meta,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? meta;
  final IconData actionIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: context.textStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const Gap(6),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.extraBold24.copyWith(
                    color: Colors.white,
                  ),
                ),
                if (meta != null) ...[
                  const Gap(4),
                  Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(16),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              actionIcon,
              size: 28,
              color: context.colorTokens.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
