import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/config/config_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/avatar_presets.dart";

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigController controller = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            Text(
              context.l10n.settingsTitle,
              style: context.textStyles.titleFont,
            ),
            const Gap(24),
            Obx(
              () => BounceTap(
                pressedScale: 0.97,
                onTap: controller.onTapMyProfile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colorTokens.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: context.colorTokens.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppAvatarPresets.byIndex(
                            controller.avatarIconIndex.value,
                          ),
                          color: Colors.white,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.userName.value.isEmpty
                                  ? context.l10n.myProfileFallback
                                  : controller.userName.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.extraBold20,
                            ),
                            if (controller.nickName.value.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIcon(
                                    "special_a",
                                    size: 12,
                                    color: context.colorTokens.textHint,
                                  ),
                                  const Gap(4),
                                  Flexible(
                                    child: Text(
                                      controller.nickName.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textStyles.bodySmall
                                          .copyWith(
                                            color: context.colorTokens.textHint,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      AppIcon(
                        "right_back",
                        size: 12,
                        color: context.colorTokens.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(28),
            _SectionLabel(context.l10n.preferencesSection),
            const Gap(8),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colorTokens.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const _IconBadge(iconName: "moon"),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        context.l10n.darkModeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: controller.isDarkMode.value,
                      onChanged: controller.onToggleDarkMode,
                      activeThumbColor: context.colorTokens.primary,
                      activeTrackColor: context.colorTokens.primaryVeryLight,
                      inactiveThumbColor: context.colorTokens.primary,
                      inactiveTrackColor: context.colorTokens.primaryVeryLight,
                      trackOutlineColor:
                          WidgetStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return context.colorTokens.primaryVeryLight;
                            }
                            return context.colorTokens.primary;
                          }),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(12),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colorTokens.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const _IconBadge(icon: Icons.notifications_none_rounded),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        context.l10n.notificationsLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: controller.notificationsEnabled.value,
                      onChanged: controller.onToggleNotifications,
                      activeThumbColor: context.colorTokens.primary,
                      activeTrackColor: context.colorTokens.primaryVeryLight,
                      inactiveThumbColor: context.colorTokens.primary,
                      inactiveTrackColor: context.colorTokens.primaryVeryLight,
                      trackOutlineColor:
                          WidgetStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return context.colorTokens.primaryVeryLight;
                            }
                            return context.colorTokens.primary;
                          }),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(12),
            Obx(
              () => _SettingsTile(
                icon: Icons.language_rounded,
                label: context.l10n.language,
                trailingText: controller.languageLabel,
                onTap: controller.onTapLanguage,
              ),
            ),
            const Gap(28),
            _SectionLabel(context.l10n.supportSection),
            const Gap(8),
            _SettingsTile(
              iconName: "faq",
              label: context.l10n.faqLabel,
              onTap: controller.onTapFaq,
            ),
            const Gap(12),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: context.l10n.aboutLabel,
              trailingText: context.l10n.appVersionLabel(
                AppConstants.appTitle,
                AppConstants.appVersion,
              ),
              onTap: null,
            ),
            const Gap(28),
            _SectionLabel(context.l10n.accountSection),
            const Gap(8),
            _SettingsTile(
              icon: Icons.logout_rounded,
              label: context.l10n.logOutLabel,
              onTap: controller.onTapLogOut,
              isDestructive: true,
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: context.textStyles.bodySmall.copyWith(
      color: context.colorTokens.textHint,
    ),
  );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({this.iconName, this.icon})
    : assert(
        iconName != null || icon != null,
        "Provide either iconName or icon",
      );

  final String? iconName;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: iconName != null
          ? AppIcon(iconName!, size: 18, color: context.colorTokens.primary)
          : Icon(icon, size: 20, color: context.colorTokens.primary),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    this.iconName,
    this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
    this.isDestructive = false,
  }) : assert(
         iconName != null || icon != null,
         "Provide either iconName or icon",
       );

  final String? iconName;
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final String? trailingText;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color tint = isDestructive
        ? context.colorTokens.error
        : context.colorTokens.primary;
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDestructive
                  ? context.colorTokens.error.withValues(alpha: 0.12)
                  : context.colorTokens.primaryVeryLight,

              shape: BoxShape.circle,
            ),
            child: Center(
              child: iconName != null
                  ? AppIcon(iconName!, size: 18, color: tint)
                  : Icon(icon, size: 20, color: tint),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge.copyWith(
                color: isDestructive ? context.colorTokens.error : null,
              ),
            ),
          ),
          if (trailingText != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                trailingText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            if (onTap != null) const Gap(8),
          ],
          if (onTap != null)
            AppIcon("right_back", size: 12, color: context.colorTokens.primary),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return BounceTap(pressedScale: 0.97, onTap: onTap!, child: content);
  }
}
