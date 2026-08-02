import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/config/config_controller.dart";
import "package:help_out/presentation/config/widgets/settings_section.dart";
import "package:help_out/presentation/config/widgets/settings_tile.dart";
import "package:help_out/presentation/config/widgets/settings_user_card.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/theme/app_spacing.dart";

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigController controller = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            Text(
              context.l10n.settingsTitle,
              style: context.textStyles.pageTitle,
            ),
            const Gap(AppSpacing.titleToDescription),
            Text(
              context.l10n.settingsSubtitle,
              style: context.textStyles.caption,
            ),
            const Gap(AppSpacing.betweenSections),
            Obx(
              () => SettingsUserCard(
                name: controller.displayName,
                nickname: controller.displayNickname,
                avatarIconIndex: controller.avatarIconIndex.value,
                profilePhotoBase64: controller.profilePhotoBase64.value,
                onTap: controller.onTapMyProfile,
              ),
            ),
            const Gap(AppSpacing.betweenSections + 4),
            Obx(
              () => SettingsSection(
                title: context.l10n.preferencesSection,
                children: [
                  SettingsTile.toggle(
                    icon: controller.isDarkMode.value
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: context.l10n.darkModeLabel,
                    subtitle: context.l10n.darkModeDisabledSubtitle,
                    value: controller.isDarkMode.value,
                    onChanged: controller.onToggleDarkMode,
                    tint: context.colorTokens.primary,
                  ),
                  SettingsTile.toggle(
                    icon: Icons.notifications_active_rounded,
                    title: context.l10n.timerNotificationsTitle,
                    subtitle: context.l10n.notificationsEnabledSubtitle,
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.onToggleNotifications,
                    tint: context.colorTokens.info,
                  ),
                  SettingsTile.navigation(
                    icon: Icons.language_rounded,
                    title: context.l10n.language,
                    subtitle: context.l10n.appLanguageSubtitle,
                    trailingText: controller.languageLabel,
                    onTap: controller.onTapLanguage,
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.betweenSections + 4),
            SettingsSection(
              title: context.l10n.helpSection,
              children: [
                SettingsTile.navigationIconName(
                  iconName: "faq",
                  title: context.l10n.faqLabel,
                  subtitle: context.l10n.faqSettingsSubtitle,
                  onTap: controller.onTapFaq,
                ),
                SettingsTile.navigation(
                  icon: Icons.feedback_outlined,
                  title: context.l10n.sendFeedbackTitle,
                  subtitle: context.l10n.sendFeedbackSubtitle,
                  onTap: controller.onTapFeedback,
                ),
              ],
            ),
            const Gap(AppSpacing.betweenSections + 4),
            SettingsSection(
              title: context.l10n.aboutSection,
              children: [
                SettingsTile.info(
                  icon: Icons.info_outline_rounded,
                  title: AppConstants.appTitle,
                  subtitle: context.l10n.appVersionValue(
                    AppConstants.appVersion,
                  ),
                ),
                if (AppConstants.useMockData && kDebugMode)
                  SettingsTile.info(
                    icon: Icons.developer_mode_rounded,
                    title: context.l10n.debugEnvironmentTitle,
                    subtitle: context.l10n.debugEnvironmentSubtitle,
                  ),
              ],
            ),
            const Gap(AppSpacing.betweenSections + 4),
            SettingsSection(
              title: context.l10n.sessionSection,
              children: [
                SettingsTile.danger(
                  icon: Icons.logout_rounded,
                  title: context.l10n.logOutLabel,
                  subtitle: context.l10n.logOutSettingsSubtitle,
                  onTap: controller.onTapLogOut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
