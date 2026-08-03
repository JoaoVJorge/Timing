import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";

enum SettingsTileVariant { navigation, toggle, info, danger }

class SettingsTile extends StatelessWidget {
  const SettingsTile.navigation({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
    this.trailingSwatch,
    this.tint,
    super.key,
  }) : iconName = null,
       value = null,
       onChanged = null,
       variant = SettingsTileVariant.navigation;

  const SettingsTile.navigationIconName({
    required this.iconName,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
    this.tint,
    super.key,
  }) : icon = null,
       value = null,
       onChanged = null,
       trailingSwatch = null,
       variant = SettingsTileVariant.navigation;

  const SettingsTile.toggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.tint,
    super.key,
  }) : iconName = null,
       onTap = null,
       trailingText = null,
       trailingSwatch = null,
       variant = SettingsTileVariant.toggle;

  const SettingsTile.info({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.tint,
    super.key,
  }) : iconName = null,
       value = null,
       onChanged = null,
       onTap = null,
       trailingSwatch = null,
       variant = SettingsTileVariant.info;

  const SettingsTile.danger({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  }) : iconName = null,
       value = null,
       onChanged = null,
       trailingText = null,
       trailingSwatch = null,
       tint = null,
       variant = SettingsTileVariant.danger;

  final IconData? icon;
  final String? iconName;
  final String title;
  final String subtitle;
  final String? trailingText;

  /// Colour preview shown before the chevron, e.g. the current accent colour.
  final Color? trailingSwatch;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final Color? tint;
  final SettingsTileVariant variant;

  bool get _isDanger => variant == SettingsTileVariant.danger;

  /// Only state carries colour here — a switch that is on, the accent swatch,
  /// the destructive row. Everything else stays neutral.
  Color _tintFor(BuildContext context) {
    if (_isDanger) {
      return context.colorTokens.error;
    }
    return tint ?? context.colorTokens.textHint;
  }

  @override
  Widget build(BuildContext context) {
    final Color tileTint = _tintFor(context);
    final Widget content = Container(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colorTokens.transparent,
      child: Row(
        children: [
          _SettingsIconBadge(icon: icon, iconName: iconName, tint: tileTint),
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
                  style: context.textStyles.cardTitle.copyWith(
                    color: _isDanger ? context.colorTokens.error : null,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.caption.copyWith(
                    color: context.isDarkMode
                        ? context.colorTokens.textHint
                        : const Color(0xFF777A7E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.betweenRelated),
          _Trailing(
            variant: variant,
            trailingText: trailingText,
            trailingSwatch: trailingSwatch,
            value: value,
            onChanged: onChanged,
            tint: _isDanger
                ? context.colorTokens.error
                : tint ?? context.colorTokens.primary,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return BounceTap(pressedScale: 0.98, onTap: onTap!, child: content);
  }
}

class _SettingsIconBadge extends StatelessWidget {
  const _SettingsIconBadge({required this.tint, this.icon, this.iconName});

  final IconData? icon;
  final String? iconName;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: tint.withValues(alpha: context.isDarkMode ? 0.18 : 0.12),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: iconName != null
          ? AppIcon(iconName!, size: 18, color: tint)
          : Icon(icon, size: 20, color: tint),
    ),
  );
}

class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.variant,
    required this.tint,
    this.trailingText,
    this.trailingSwatch,
    this.value,
    this.onChanged,
  });

  final SettingsTileVariant variant;
  final String? trailingText;
  final Color? trailingSwatch;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    if (variant == SettingsTileVariant.toggle) {
      return Switch(
        value: value ?? false,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        activeThumbColor: context.colorTokens.white,
        activeTrackColor: tint,
        inactiveThumbColor: context.colorTokens.white,
        inactiveTrackColor: const Color(0xFFD7D9DC),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => context.colorTokens.transparent,
        ),
      );
    }

    if (variant == SettingsTileVariant.info) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 112),
        child: Text(
          trailingText ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: context.textStyles.caption.copyWith(fontSize: 12),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailingSwatch != null) ...[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: trailingSwatch,
              shape: BoxShape.circle,
              border: Border.all(color: context.colorTokens.borderUnfocused),
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
        ],
        if (trailingText != null) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 104),
            child: Text(
              trailingText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: context.textStyles.caption.copyWith(fontSize: 12),
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
        ],
        Icon(
          Icons.chevron_right_rounded,
          size: 22,
          color: variant == SettingsTileVariant.danger
              ? tint
              : context.colorTokens.textHint,
        ),
      ],
    );
  }
}
