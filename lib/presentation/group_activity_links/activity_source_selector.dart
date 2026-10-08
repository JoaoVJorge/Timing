import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/theme/app_spacing.dart";

class ActivitySourceSelector extends StatelessWidget {
  const ActivitySourceSelector({
    super.key,
    required this.useExisting,
    required this.options,
    required this.selectedIds,
    required this.onModeChanged,
    required this.onToggle,
    this.isReading = false,
    this.title,
    this.accent,
  });

  final bool useExisting;
  final List<GroupActivitySourceOption> options;
  final Set<String> selectedIds;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<String> onToggle;
  final bool isReading;
  final String? title;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color color = accent ?? context.colorTokens.primary;
    return CreationConfigCard(
      accent: color,
      header: CreationSectionHeader(
        icon: Icons.link_rounded,
        label: title ?? context.l10n.groupLinksTitle,
        accent: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LinkModeOption(
            title: context.l10n.groupLinksUseExisting,
            icon: Icons.checklist_rounded,
            selected: useExisting,
            accent: color,
            onTap: () => onModeChanged(true),
          ),
          const Gap(10),
          _LinkModeOption(
            title: context.l10n.groupLinksCreateNew,
            icon: Icons.add_rounded,
            selected: !useExisting,
            accent: color,
            onTap: () => onModeChanged(false),
          ),
          if (useExisting) ...[
            const Gap(AppSpacing.betweenSections),
            Text(
              context.l10n.groupLinksSelected(selectedIds.length),
              style: context.textStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(AppSpacing.betweenRelated),
            if (options.isEmpty)
              Text(
                context.l10n.groupLinksEmpty,
                style: context.textStyles.caption,
              ),
            for (final option in options) ...[
              Material(
                clipBehavior: Clip.antiAlias,
                color: selectedIds.contains(option.id)
                    ? color.withValues(alpha: 0.08)
                    : context.colorTokens.surfaceInnerLayer.withValues(
                        alpha: 0.3,
                      ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selectedIds.contains(option.id)
                        ? color.withValues(alpha: 0.5)
                        : context.colorTokens.borderUnfocused.withValues(
                            alpha: 0.55,
                          ),
                  ),
                ),
                child: CheckboxListTile(
                  key: ValueKey('source_${option.id}'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: color,
                  checkColor: context.colorTokens.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    option.name,
                    style: context.textStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  value: selectedIds.contains(option.id),
                  onChanged: (_) => onToggle(option.id),
                ),
              ),
              const Gap(8),
            ],
          ],
          const Gap(AppSpacing.betweenRelated),
          Container(
            padding: AppSpacing.tile,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: color, size: 20),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.groupLinksExplanation,
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colorTokens.textHint,
                          height: 1.4,
                        ),
                      ),
                      if (isReading) ...[
                        const Gap(8),
                        Text(
                          context.l10n.groupLinksReadingHint,
                          style: context.textStyles.bodySmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkModeOption extends StatelessWidget {
  const _LinkModeOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: BounceTap(
      behavior: HitTestBehavior.opaque,
      pressedScale: 0.98,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 60),
        padding: AppSpacing.tile,
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.08)
              : context.colorTokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.68)
                : context.colorTokens.borderUnfocused.withValues(alpha: 0.7),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? accent : context.colorTokens.textHint,
              size: 24,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                title,
                style: context.textStyles.bodyMedium.copyWith(
                  color: selected ? accent : context.colorTokens.textBody,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Gap(10),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? accent : context.colorTokens.borderUnfocused,
              size: 24,
            ),
          ],
        ),
      ),
    ),
  );
}
