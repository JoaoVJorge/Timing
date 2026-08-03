import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

typedef HomeActivity = ({
  TimeCategoryType category,
  String label,
  String value,
});

/// Activity areas displayed as large tappable rows, matching the category list
/// pattern used elsewhere in the app.
class HomeActivityGrid extends StatelessWidget {
  const HomeActivityGrid({
    required this.activities,
    required this.onTapActivity,
    super.key,
  });

  final List<HomeActivity> activities;
  final ValueChanged<TimeCategoryType> onTapActivity;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (int index = 0; index < activities.length; index++) ...[
        if (index > 0) const Gap(10),
        _ActivityTile(
          activity: activities[index],
          onTap: () => onTapActivity(activities[index].category),
        ),
      ],
    ],
  );
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.onTap});

  final HomeActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = context.colorTokens.primary;
    final _ActivityStyle style = _ActivityStyle.fromPrimaryColor(
      accent,
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
    );

    return BounceTap(
      pressedScale: 0.985,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.surfaceShadow,
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.badgeBackground,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 23,
                child: ClipRect(
                  child: AppIcon(
                    activity.category.iconName,
                    size: 23,
                    color: style.accent,
                  ),
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.cardTitle.copyWith(fontSize: 16),
                  ),
                  const Gap(3),
                  Text(
                    activity.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.caption.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Icon(Icons.chevron_right_rounded, size: 28, color: accent),
          ],
        ),
      ),
    );
  }
}

class _ActivityStyle {
  const _ActivityStyle({
    required this.background,
    required this.badgeBackground,
    required this.accent,
  });

  final Color background;
  final Color badgeBackground;
  final Color accent;

  factory _ActivityStyle.fromPrimaryColor(
    Color accent, {
    required bool isDarkMode,
  }) {
    return _ActivityStyle(
      background: isDarkMode
          ? Color.lerp(const Color(0xFF1E1E1E), accent, 0.08) ??
                const Color(0xFF1E1E1E)
          : Colors.white,
      badgeBackground: accent.withValues(alpha: isDarkMode ? 0.18 : 0.13),
      accent: accent,
    );
  }
}
