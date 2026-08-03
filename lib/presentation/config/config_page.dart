import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
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
                profilePhotoBytes: controller.profilePhotoBytes,
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
                    tint: const Color(0xFF6C5CE7),
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
                    tint: const Color(0xFF2684D5),
                  ),
                  SettingsTile.navigation(
                    icon: Icons.lock_clock_rounded,
                    title: "Modo concentração",
                    subtitle: "Escolha quais focos bloqueiam a saída do app.",
                    onTap: () =>
                        _showConcentrationModeSheet(context, controller),
                    tint: const Color(0xFF7C3AED),
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
                  tint: context.colorTokens.success,
                ),
                SettingsTile.navigation(
                  icon: Icons.feedback_outlined,
                  title: context.l10n.sendFeedbackTitle,
                  subtitle: context.l10n.sendFeedbackSubtitle,
                  onTap: controller.onTapFeedback,
                  tint: context.colorTokens.info,
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
                  tint: context.colorTokens.textHint,
                ),
                if (AppConstants.useMockData && kDebugMode)
                  SettingsTile.info(
                    icon: Icons.developer_mode_rounded,
                    title: context.l10n.debugEnvironmentTitle,
                    subtitle: context.l10n.debugEnvironmentSubtitle,
                    tint: context.colorTokens.textHint,
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

  void _showConcentrationModeSheet(
    BuildContext context,
    ConfigController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.82,
        child: SafeArea(
          child: Obx(
            () => ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              children: [
                Text(
                  "Modo concentração",
                  style: context.textStyles.sectionTitle.copyWith(fontSize: 18),
                ),
                const Gap(6),
                Text(
                  "Ao ativar uma atividade, o app tenta manter você dentro do foco até pausar ou encerrar.",
                  style: context.textStyles.caption,
                ),
                const Gap(AppSpacing.betweenRelated),
                SettingsSection(
                  title: "Atividades",
                  children: [
                    SettingsTile.toggle(
                      icon: Icons.school_rounded,
                      title: "Estudo",
                      subtitle: "Impede sair do app durante focos de estudo.",
                      value: controller.focusLockStudyingEnabled.value,
                      onChanged: (value) => controller.onToggleFocusLock(
                        TimeCategoryType.studying,
                        value,
                      ),
                      tint: const Color(0xFF2F80ED),
                    ),
                    SettingsTile.toggle(
                      icon: Icons.fitness_center_rounded,
                      title: "Exercícios",
                      subtitle:
                          "Impede sair do app durante focos de exercício.",
                      value: controller.focusLockExercisesEnabled.value,
                      onChanged: (value) => controller.onToggleFocusLock(
                        TimeCategoryType.exercises,
                        value,
                      ),
                      tint: const Color(0xFF27AE60),
                    ),
                    SettingsTile.toggle(
                      icon: Icons.menu_book_rounded,
                      title: "Leitura",
                      subtitle: "Impede sair do app durante focos de leitura.",
                      value: controller.focusLockReadingEnabled.value,
                      onChanged: (value) => controller.onToggleFocusLock(
                        TimeCategoryType.reading,
                        value,
                      ),
                      tint: const Color(0xFFF2994A),
                    ),
                    SettingsTile.toggle(
                      icon: Icons.palette_rounded,
                      title: "Hobbie",
                      subtitle: "Impede sair do app durante focos de hobbie.",
                      value: controller.focusLockHobbiesEnabled.value,
                      onChanged: (value) => controller.onToggleFocusLock(
                        TimeCategoryType.hobbies,
                        value,
                      ),
                      tint: const Color(0xFF9B51E0),
                    ),
                  ],
                ),
                const Gap(8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
