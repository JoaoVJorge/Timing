import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/progress/progress_category_style.dart";
import "package:timing/presentation/progress/progress_controller.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/theme/subject_icons.dart";

/// A ranked activity row inside the shared distribution card.
class ProgressActivityCard extends StatelessWidget {
  const ProgressActivityCard({
    required this.activity,
    this.rank = 1,
    this.onTap,
    super.key,
  });

  final ProgressActivitySummary activity;
  final int rank;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = activity.category.accentColor;
    final double share = activity.share.clamp(0, 1);
    final int percent = (share * 100).round();
    final String value = activity.isReading
        ? context.l10n.metricPagesValue(activity.pages)
        : formatDurationLong(Duration(seconds: activity.seconds));
    final String shareDescription = activity.isReading
        ? context.l10n.progressActivityPagesShare(percent)
        : context.l10n.progressActivityTimeShare(percent);
    final IconData? customIcon = SubjectIcons.byName(activity.iconName);

    return Semantics(
      label: "$rank. ${activity.name}, $value, $shareDescription",
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
            child: Row(
              children: [
                Text(
                  "$rank",
                  style: context.textStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: activity.iconName.isEmpty
                      ? Icon(
                          _categoryIcon(activity.category),
                          size: 24,
                          color: color,
                        )
                      : customIcon != null
                      ? Icon(customIcon, size: 24, color: color)
                      : AppIcon(activity.iconName, size: 24, color: color),
                ),
                const Gap(12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final Widget name = Text(
                        activity.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      );
                      final Widget amount = Text(
                        value,
                        style: context.textStyles.bodyMedium.copyWith(
                          color: context.colorTokens.textHint,
                        ),
                      );
                      final bool stacked =
                          constraints.maxWidth < 170 ||
                          MediaQuery.textScalerOf(context).scale(14) > 20;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (stacked) ...[
                            name,
                            const Gap(2),
                            amount,
                          ] else
                            Row(
                              children: [
                                Expanded(child: name),
                                const Gap(8),
                                amount,
                              ],
                            ),
                          const Gap(8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: share,
                                  minHeight: 7,
                                  borderRadius: BorderRadius.circular(999),
                                  backgroundColor: color.withValues(
                                    alpha: 0.12,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color,
                                  ),
                                ),
                              ),
                              const Gap(10),
                              Text(
                                "$percent%",
                                style: context.textStyles.caption.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Gap(8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: context.colorTokens.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _categoryIcon(TimeCategoryType category) => switch (category) {
  TimeCategoryType.studying => Icons.school_rounded,
  TimeCategoryType.exercises => Icons.fitness_center_rounded,
  TimeCategoryType.reading => Icons.auto_stories_rounded,
  TimeCategoryType.hobbies => Icons.palette_rounded,
};
