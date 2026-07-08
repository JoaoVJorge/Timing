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

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigController controller = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            Text(
              context.l10n.settingsTitle,
              style: context.textStyles.titleFont,
            ),
            const Gap(8),
            Text(
              context.l10n.settingsSubtitle,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
            const Gap(24),
            Obx(
              () => SettingsUserCard(
                name: controller.displayName,
                nickname: controller.displayNickname,
                avatarIconIndex: controller.avatarIconIndex.value,
                onTap: controller.onTapMyProfile,
              ),
            ),
            const Gap(28),
            Obx(
              () => SettingsSection(
                title: context.l10n.preferencesSection,
                children: [
                  SettingsTile.toggle(
                    icon: controller.isDarkMode.value
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: context.l10n.darkModeLabel,
                    subtitle: controller.darkModeSubtitle,
                    value: controller.isDarkMode.value,
                    onChanged: controller.onToggleDarkMode,
                    tint: context.colorTokens.primary,
                  ),
                  SettingsTile.navigation(
                    icon: Icons.palette_rounded,
                    title: context.l10n.accentColorSettingsTitle,
                    subtitle: context.l10n.accentColorSettingsSubtitle,
                    trailingText: context.l10n.editButton,
                    tint: controller.accentColor.value,
                    onTap: controller.onTapAccentColor,
                  ),
                  SettingsTile.toggle(
                    icon: Icons.notifications_active_rounded,
                    title: context.l10n.timerNotificationsTitle,
                    subtitle: controller.notificationsSubtitle,
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.onToggleNotifications,
                    tint: const Color(0xFF1FA2A6),
                  ),
                  SettingsTile.navigation(
                    icon: Icons.language_rounded,
                    title: context.l10n.language,
                    subtitle: context.l10n.appLanguageSubtitle,
                    trailingText: controller.languageLabel,
                    tint: const Color(0xFF2E6ADE),
                    onTap: controller.onTapLanguage,
                  ),
                ],
              ),
            ),
            const Gap(28),
            SettingsSection(
              title: context.l10n.helpSection,
              children: [
                SettingsTile.navigationIconName(
                  iconName: "faq",
                  title: context.l10n.faqLabel,
                  subtitle: context.l10n.faqSettingsSubtitle,
                  tint: const Color(0xFF3FA65D),
                  onTap: controller.onTapFaq,
                ),
                SettingsTile.navigation(
                  icon: Icons.feedback_outlined,
                  title: context.l10n.sendFeedbackTitle,
                  subtitle: context.l10n.sendFeedbackSubtitle,
                  tint: const Color(0xFF1FA2A6),
                  onTap: controller.onTapFeedback,
                ),
              ],
            ),
            const Gap(28),
            SettingsSection(
              title: context.l10n.aboutSection,
              children: [
                SettingsTile.info(
                  icon: Icons.info_outline_rounded,
                  title: AppConstants.appTitle,
                  subtitle: context.l10n.appVersionValue(
                    AppConstants.appVersion,
                  ),
                  tint: context.colorTokens.textHint,
                ),
                if (AppConstants.useMockData)
                  SettingsTile.info(
                    icon: Icons.developer_mode_rounded,
                    title: context.l10n.debugEnvironmentTitle,
                    subtitle: context.l10n.debugEnvironmentSubtitle,
                    tint: context.colorTokens.textHint,
                  ),
              ],
            ),
            const Gap(28),
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
