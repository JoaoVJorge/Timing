part of "create_group_page.dart";

class _InformationStep extends StatelessWidget {
  const _InformationStep({
    required this.controller,
    required this.groupNameKey,
    required this.themeKey,
    required this.linksKey,
    required this.onSelectTheme,
  });

  final CreateGroupController controller;
  final Key groupNameKey;
  final Key themeKey;
  final Key linksKey;
  final ValueChanged<GroupThemeType> onSelectTheme;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _AboutGroupCard(key: groupNameKey, controller: controller),
      const Gap(24),
      _CreateGroupSectionHeader(
        key: themeKey,
        icon: Icons.emoji_events_rounded,
        title: context.l10n.groupThemeLabel,
        description: context.l10n.createGroupThemeMetricDescription,
      ),
      const Gap(14),
      Obx(() {
        final GroupThemeType? selected = controller.selectedTheme.value;

        return Column(
          children: [
            _ThemeGrid(selectedTheme: selected, onSelectTheme: onSelectTheme),
            if (selected != null) ...[
              const Gap(18),
              _LinkedActivitiesSection(
                key: linksKey,
                controller: controller,
                theme: selected,
              ),
            ],
          ],
        );
      }),
    ],
  );
}

class _AboutGroupCard extends StatelessWidget {
  const _AboutGroupCard({required this.controller, super.key});

  final CreateGroupController controller;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: context.colorTokens.primary.withValues(alpha: 0.12),
      ),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow,
          blurRadius: 14,
          offset: const Offset(0, 4),
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
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: AppIcon(
                  "group",
                  size: 21,
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
                    context.l10n.createGroupAboutTitle,
                    style: context.textStyles.sectionTitle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    context.l10n.createGroupAboutDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(18),
        _CreateGroupFieldLabel(context.l10n.groupNameLabel),
        const Gap(7),
        TextField(
          controller: controller.groupNameController,
          onChanged: controller.onGroupNameChanged,
          style: context.textStyles.inputText.copyWith(
            fontWeight: FontWeight.w600,
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
        const Gap(14),
        _CreateGroupFieldLabel(context.l10n.createGroupDescriptionLabel),
        const Gap(7),
        TextField(
          controller: controller.descriptionController,
          minLines: 1,
          maxLines: 3,
          maxLength: 280,
          style: context.textStyles.inputText.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: _roundedFieldDecoration(
            context,
            hintText: context.l10n.createGroupDescriptionHint,
            prefixIcon: Icon(
              Icons.notes_rounded,
              size: 21,
              color: context.colorTokens.primary,
            ),
          ),
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
      fontSize: 14,
      fontWeight: FontWeight.w600,
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
      fillColor: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: context.colorTokens.borderUnfocused),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: context.colorTokens.borderUnfocused),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, size: 23, color: context.colorTokens.primary),
      ),
      const Gap(12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textStyles.sectionTitle),
            const Gap(3),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
                fontWeight: FontWeight.w600,
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
      const double spacing = 10;
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

/// The creator's activities of the chosen theme. Linking is optional here:
/// the same choice stays available from the group's menu.
class _LinkedActivitiesSection extends StatelessWidget {
  const _LinkedActivitiesSection({
    required this.controller,
    required this.theme,
    super.key,
  });

  final CreateGroupController controller;
  final GroupThemeType theme;

  @override
  Widget build(BuildContext context) => Obx(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          groupLinksHint(context, theme),
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
        const Gap(4),
        Text(
          context.l10n.createGroupLinksOptional,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
        const Gap(12),
        if (controller.isLoadingSources.value) const LinearProgressIndicator(),
        if (controller.sourcesLoadFailed.value)
          TextButton(
            onPressed: controller.loadPersonalActivities,
            child: Text(context.l10n.groupLinksRetry),
          ),
        ActivitySourceSelector(
          options: controller.compatibleSources,
          selectedIds: controller.selectedSourceIds.toSet(),
          singleSelection: theme == GroupThemeType.dailyGoals,
          onToggle: controller.toggleSource,
        ),
      ],
    ),
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
        constraints: const BoxConstraints(minHeight: 98),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorTokens.primaryVeryLight
              : context.colorTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? context.colorTokens.primary
                : context.colorTokens.borderUnfocused,
            width: isSelected ? 1.6 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? context.colorTokens.primary.withValues(alpha: 0.12)
                  : context.colorTokens.surfaceShadow,
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.colorTokens.primaryVeryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: AppIcon(
                        theme.iconName,
                        size: 21,
                        color: context.colorTokens.primary,
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.localizedLabel(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodyLarge.copyWith(
                            color: isSelected
                                ? context.colorTokens.primary
                                : context.colorTokens.textBody,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          groupMetricDescription(context, theme),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colorTokens.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  key: ValueKey(isSelected),
                  size: 21,
                  color: isSelected
                      ? context.colorTokens.primary
                      : context.colorTokens.borderUnfocused,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
