import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon_badge.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// Third hierarchy level: a secondary destination. Rows live inside an
/// [AppNavRowGroup] instead of each pretending to be an independent card.
class AppNavRow extends StatelessWidget {
  const AppNavRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colorTokens.transparent,
      child: Row(
        children: [
          AppIconBadge(icon: icon, color: iconColor),
          const Gap(AppSpacing.betweenRelated),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.cardTitle,
                ),
                if (subtitle != null) ...[
                  const Gap(2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
          trailing ??
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: context.colorTokens.textHint,
              ),
        ],
      ),
    ),
  );
}

/// Groups related [AppNavRow]s behind one border, separated by dividers.
class AppNavRowGroup extends StatelessWidget {
  const AppNavRowGroup({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: AppSurfaces.rowGroup(context.colorTokens),
    child: Column(
      children: [
        for (int index = 0; index < rows.length; index++) ...[
          if (index > 0)
            Divider(
              height: 1,
              indent: 68,
              endIndent: 16,
              color: context.colorTokens.divider,
            ),
          rows[index],
        ],
      ],
    ),
  );
}
