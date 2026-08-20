import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/app_spacing.dart";

/// Hero card at the top of Home carrying the single next best action:
/// resume a subject, start the suggested one, or create the first subject.
class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    required this.eyebrow,
    required this.title,
    required this.actionIconName,
    required this.onTap,
    this.meta,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? meta;
  final String actionIconName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colorTokens.primary,
            Color.lerp(
                  context.colorTokens.primary,
                  Colors.white,
                  context.isDarkMode ? 0.08 : 0.16,
                ) ??
                context.colorTokens.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
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
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.school_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(AppSpacing.titleToDescription),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.extraBold24.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                if (meta != null) ...[
                  const Gap(4),
                  Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(16),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox.square(
                dimension: actionIconName == "plus" ? 22 : 20,
                child: ClipRect(
                  child: AppIcon(
                    actionIconName,
                    size: actionIconName == "plus" ? 22 : 20,
                    color: context.colorTokens.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
