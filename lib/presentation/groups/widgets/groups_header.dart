import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";

/// Groups owns everything social, so Friends is reachable from here instead of
/// sitting in the middle of the Progress statistics.
class GroupsHeader extends StatelessWidget {
  const GroupsHeader({required this.onTapCreateGroup, super.key});

  final VoidCallback onTapCreateGroup;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.groupsTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.pageTitle,
            ),
            const Gap(AppSpacing.titleToDescription),
            Text(
              context.l10n.groupsSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.caption,
            ),
          ],
        ),
      ),
      const Gap(AppSpacing.betweenRelated),
      _HeaderAction(
        icon: Icons.add_rounded,
        semanticLabel: context.l10n.groupHeaderCreateButton,
        onTap: onTapCreateGroup,
      ),
    ],
  );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
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
      pressedScale: 0.94,
      onTap: onTap,
      child: Container(
        width: AppSpacing.minTapTarget,
        height: AppSpacing.minTapTarget,
        decoration: BoxDecoration(
          color: context.colorTokens.primaryVeryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: context.colorTokens.primary),
      ),
    ),
  );
}
