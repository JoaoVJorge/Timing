import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

enum SettingsTileVariant { navigation, toggle, info, danger }

class SettingsTile extends StatelessWidget {
  const SettingsTile.navigation({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
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
       tint = null,
       variant = SettingsTileVariant.danger;

  final IconData? icon;
  final String? iconName;
  final String title;
  final String subtitle;
  final String? trailingText;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final Color? tint;
  final SettingsTileVariant variant;

  bool get _isDanger => variant == SettingsTileVariant.danger;

  @override
  Widget build(BuildContext context) {
    final Color tileTint = _isDanger
        ? context.colorTokens.error
        : tint ?? context.colorTokens.primary;
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isDanger
              ? context.colorTokens.error.withValues(alpha: 0.16)
              : context.colorTokens.borderUnfocused.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          _SettingsIconBadge(icon: icon, iconName: iconName, tint: tileTint),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge.copyWith(
                    color: _isDanger ? context.colorTokens.error : null,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          _Trailing(
            variant: variant,
            trailingText: trailingText,
            value: value,
            onChanged: onChanged,
            tint: tileTint,
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
  const _SettingsIconBadge({this.icon, this.iconName, required this.tint});

  final IconData? icon;
  final String? iconName;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: tint.withValues(alpha: 0.12),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: iconName != null
          ? AppIcon(iconName!, size: 18, color: tint)
          : Icon(icon, size: 21, color: tint),
    ),
  );
}

class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.variant,
    required this.tint,
    this.trailingText,
    this.value,
    this.onChanged,
  });

  final SettingsTileVariant variant;
  final String? trailingText;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    if (variant == SettingsTileVariant.toggle) {
      return Switch(
        value: value ?? false,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: tint,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: context.colorTokens.textHint.withValues(
          alpha: 0.28,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => Colors.transparent,
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
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailingText != null) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 104),
            child: Text(
              trailingText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Gap(8),
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
