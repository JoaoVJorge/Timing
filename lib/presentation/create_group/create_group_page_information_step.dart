part of "create_group_page.dart";

class _InformationStep extends StatelessWidget {
  const _InformationStep({required this.controller, required this.themeKey});

  final CreateGroupController controller;
  final Key themeKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.createGroupDescriptionLabel,
              style: context.textStyles.bodySmall,
            ),
            const Gap(8),
            TextField(
              controller: controller.descriptionController,
              minLines: 2,
              maxLines: 4,
              maxLength: 280,
              style: context.textStyles.inputText,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.createGroupDescriptionHint,
              ),
            ),
          ],
        ),
      ),
      const Gap(18),
      Text(
        context.l10n.groupThemeLabel,
        key: themeKey,
        style: context.textStyles.bodyLarge,
      ),
      const Gap(4),
      Text(
        context.l10n.createGroupThemeMetricDescription,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.textHint,
        ),
      ),
      const Gap(12),
      Obx(() {
        final GroupThemeType? selected = controller.selectedTheme.value;

        return Column(
          children: [
            for (final GroupThemeType theme in GroupThemeType.values) ...[
              _ThemeRow(
                theme: theme,
                isSelected: theme == selected,
                onTap: () => controller.onSelectTheme(theme),
              ),
              const Gap(8),
            ],
          ],
        );
      }),
    ],
  );
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final GroupThemeType theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
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
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.localizedLabel(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge,
                ),
                const Gap(2),
                Text(
                  groupMetricDescription(context, theme),
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
          Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 22,
            color: isSelected
                ? context.colorTokens.primary
                : context.colorTokens.borderUnfocused,
          ),
        ],
      ),
    ),
  );
}
