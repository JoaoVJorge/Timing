import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

typedef HomeActivity = ({
  TimeCategoryType category,
  String label,
  String value,
  String meta,
});

/// 2x2 grid of activity areas. Each tile carries its own headline figure so the
/// grid replaces the separate row of metric cards instead of duplicating it.
class HomeActivityGrid extends StatelessWidget {
  const HomeActivityGrid({
    required this.activities,
    required this.onTapActivity,
    super.key,
  });

  final List<HomeActivity> activities;
  final ValueChanged<TimeCategoryType> onTapActivity;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const double spacing = AppSpacing.betweenRelated;
      final double tileWidth = (constraints.maxWidth - spacing) / 2;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final HomeActivity activity in activities)
            SizedBox(
              width: tileWidth,
              child: _ActivityTile(
                activity: activity,
                onTap: () => onTapActivity(activity.category),
              ),
            ),
        ],
      );
    },
  );
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.onTap});

  final HomeActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(14),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: 19,
              child: ClipRect(
                child: AppIcon(
                  activity.category.iconName,
                  size: 19,
                  color: context.colorTokens.primary,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.betweenRelated),
          Text(
            activity.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.cardTitle.copyWith(fontSize: 15),
          ),
          const Gap(4),
          Text(
            activity.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.metricValue.copyWith(fontSize: 20),
          ),
          const Gap(2),
          Text(
            activity.meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption.copyWith(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
