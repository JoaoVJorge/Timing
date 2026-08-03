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

  Future<void> _showConcentrationModeSheet(
    BuildContext context,
    ConfigController controller,
  ) async {
    final studying = controller.focusLockStudyingEnabled.value.obs;
    final exercises = controller.focusLockExercisesEnabled.value.obs;
    final reading = controller.focusLockReadingEnabled.value.obs;
    final hobbies = controller.focusLockHobbiesEnabled.value.obs;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colorTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.82,
        child: SafeArea(
          child: Obx(
            () => Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.colorTokens.borderUnfocused,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const Gap(26),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ConcentrationHeroBadge(),
                      const Gap(18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Modo concentração",
                              style: context.textStyles.extraBold24,
                            ),
                            const Gap(8),
                            Text(
                              "Quando ativado, o app ajuda você a se manter focado durante a atividade até pausar ou finalizar.",
                              style: context.textStyles.bodyMedium.copyWith(
                                color: context.colorTokens.textHint,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(28),
                  Text(
                    "Atividades",
                    style: context.textStyles.sectionTitle.copyWith(
                      color: context.colorTokens.primary,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _ConcentrationActivityTile(
                          icon: Icons.school_rounded,
                          title: "Estudo",
                          subtitle: "Foco total nos seus estudos.",
                          color: const Color(0xFF2F80ED),
                          value: studying.value,
                          onChanged: (value) => studying.value = value,
                        ),
                        const Gap(10),
                        _ConcentrationActivityTile(
                          icon: Icons.fitness_center_rounded,
                          title: "Exercícios",
                          subtitle: "Concentre-se nos seus treinos.",
                          color: const Color(0xFF27AE60),
                          value: exercises.value,
                          onChanged: (value) => exercises.value = value,
                        ),
                        const Gap(10),
                        _ConcentrationActivityTile(
                          icon: Icons.menu_book_rounded,
                          title: "Leitura",
                          subtitle: "Mergulhe nas suas leituras.",
                          color: const Color(0xFFF2994A),
                          value: reading.value,
                          onChanged: (value) => reading.value = value,
                        ),
                        const Gap(10),
                        _ConcentrationActivityTile(
                          icon: Icons.sports_esports_rounded,
                          title: "Hobbies",
                          subtitle: "Aproveite seus hobbies com foco.",
                          color: const Color(0xFF9B51E0),
                          value: hobbies.value,
                          onChanged: (value) => hobbies.value = value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await controller.onSaveFocusLockPreferences(
      studying: studying.value,
      exercises: exercises.value,
      reading: reading.value,
      hobbies: hobbies.value,
    );
  }
}

class _ConcentrationHeroBadge extends StatelessWidget {
  const _ConcentrationHeroBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.primaryVeryLight,
        border: Border.all(color: tokens.primary.withValues(alpha: 0.16)),
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.primary.withValues(alpha: 0.10),
          ),
          child: Icon(
            Icons.shield_moon_rounded,
            color: tokens.primary,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class _ConcentrationActivityTile extends StatelessWidget {
  const _ConcentrationActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;

    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tokens.borderUnfocused.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.surfaceShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: context.textStyles.cardTitle),
                const Gap(4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.caption.copyWith(
                    color: tokens.textHint,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: tokens.white,
            activeTrackColor: color,
            inactiveThumbColor: tokens.white,
            inactiveTrackColor: tokens.borderUnfocused,
            trackOutlineColor: WidgetStateProperty.all(tokens.transparent),
          ),
        ],
      ),
    );
  }
}
