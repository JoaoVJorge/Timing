part of "create_group_page.dart";

class _InformationStep extends StatelessWidget {
  const _InformationStep({
    required this.controller,
    required this.groupNameKey,
    required this.themeKey,
    required this.onSelectTheme,
  });

  final CreateGroupController controller;
  final Key groupNameKey;
  final Key themeKey;
  final ValueChanged<GroupThemeType> onSelectTheme;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _AboutGroupCard(key: groupNameKey, controller: controller),
      const Gap(18),
      _CreateGroupSectionHeader(
        key: themeKey,
        icon: Icons.emoji_events_rounded,
        title: context.l10n.createGroupRankingThemeTitle,
        description: context.l10n.createGroupThemeMetricDescription,
      ),
      const Gap(14),
      Obx(
        () => _ThemeGrid(
          selectedTheme: controller.selectedTheme.value,
          onSelectTheme: onSelectTheme,
        ),
      ),
      const Gap(16),
      const _ActivitiesLaterHint(),
      const Gap(4),
    ],
  );
}

class _AboutGroupCard extends StatelessWidget {
  const _AboutGroupCard({required this.controller, super.key});

  final CreateGroupController controller;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.colorTokens.borderUnfocused),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow,
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: AppIcon(
                  "group",
                  size: 20,
                  color: context.colorTokens.primary,
                ),
              ),
            ),
            const Gap(11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.createGroupAboutTitle,
                    style: context.textStyles.bodyMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    context.l10n.createGroupAboutDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(20),
        _CreateGroupFieldLabel(context.l10n.groupNameLabel),
        const Gap(8),
        TextField(
          controller: controller.groupNameController,
          onChanged: controller.onGroupNameChanged,
          style: context.textStyles.inputText.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: _roundedFieldDecoration(
            context,
            hintText: context.l10n.groupNameExampleHint,
            prefixIcon: AppIcon(
              "group",
              size: 20,
              color: context.colorTokens.primary,
            ),
          ),
        ),
        const Gap(18),
        _CreateGroupFieldLabel(context.l10n.createGroupDescriptionLabel),
        const Gap(8),
        TextField(
          controller: controller.descriptionController,
          minLines: 3,
          maxLines: 3,
          maxLength: 280,
          style: context.textStyles.inputText.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: _roundedFieldDecoration(
            context,
            hintText: context.l10n.createGroupDescriptionHint,
          ).copyWith(counterText: ""),
        ),
      ],
    ),
  );
}

class _CreateGroupFieldLabel extends StatelessWidget {
  const _CreateGroupFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: context.textStyles.bodyMedium.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
  );
}

InputDecoration _roundedFieldDecoration(
  BuildContext context, {
  required String hintText,
  Widget? prefixIcon,
}) =>
    AppInputDecoration.withBorder(
      tokens: context.colorTokens,
      hintText: hintText,
      prefixIcon: prefixIcon,
    ).copyWith(
      filled: true,
      fillColor: context.creationPageBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colorTokens.borderUnfocused),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colorTokens.borderUnfocused),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colorTokens.primary, width: 1.4),
      ),
    );

class _CreateGroupSectionHeader extends StatelessWidget {
  const _CreateGroupSectionHeader({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.colorTokens.primaryVeryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 22, color: context.colorTokens.primary),
      ),
      const Gap(14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textStyles.bodyMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.selectedTheme, required this.onSelectTheme});

  final GroupThemeType? selectedTheme;
  final ValueChanged<GroupThemeType> onSelectTheme;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final int columns = constraints.maxWidth < 340 ? 1 : 2;
      const double spacing = 12;
      final double tileWidth =
          (constraints.maxWidth - (spacing * (columns - 1))) / columns;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final GroupThemeType theme in GroupThemeType.values)
            SizedBox(
              width: tileWidth,
              child: _ThemeTile(
                theme: theme,
                isSelected: theme == selectedTheme,
                onTap: () => onSelectTheme(theme),
              ),
            ),
        ],
      );
    },
  );
}

class _ActivitiesLaterHint extends StatelessWidget {
  const _ActivitiesLaterHint();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(
          Icons.info_outline_rounded,
          size: 19,
          color: context.colorTokens.textHint,
        ),
      ),
      const Gap(12),
      Expanded(
        child: Text(
          context.l10n.createGroupActivitiesLaterHint,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textHint,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ),
    ],
  );
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final GroupThemeType theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    child: BounceTap(
      pressedScale: 0.97,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? context.colorTokens.primary
                : context.colorTokens.borderUnfocused,
            width: isSelected ? 2 : 1,
          ),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: theme == GroupThemeType.hobbies
                    ? Icon(
                        Icons.palette_outlined,
                        size: 22,
                        color: context.colorTokens.primary,
                      )
                    : AppIcon(
                        theme.iconName,
                        size: 21,
                        color: context.colorTokens.primary,
                      ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.localizedLabel(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? context.colorTokens.primary
                          : context.colorTokens.textBody,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    _capitalizedMetric(context, theme),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _capitalizedMetric(BuildContext context, GroupThemeType theme) {
  final String metric = groupMetricDescription(context, theme);
  if (metric.isEmpty) return metric;
  return "${metric[0].toUpperCase()}${metric.substring(1)}";
}
