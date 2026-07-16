import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// A selectable group theme shown as the theme name next to a circle holding
/// its icon. Mirrors the friend-selection highlight used elsewhere.
class GroupThemeTile extends StatelessWidget {
  const GroupThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final GroupThemeType theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? context.colorTokens.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                theme.iconName,
                size: 20,
                color: context.colorTokens.primary,
              ),
            ),
          ),
          const Gap(10),
          Text(
            theme.localizedLabel(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyMedium.copyWith(
              color: isSelected
                  ? context.colorTokens.primary
                  : context.colorTokens.textBody,
            ),
          ),
          const Gap(3),
          Flexible(
            child: Text(
              groupMetricDescription(context, theme),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
