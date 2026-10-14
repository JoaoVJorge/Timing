import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/theme/app_spacing.dart";

/// Picks which of the member's own activities count for a group. [options]
/// already holds only what fits the group's theme. A daily-goals group takes
/// one goal, so with [singleSelection] choosing another replaces the current
/// one; tapping the chosen one always clears it.
class ActivitySourceSelector extends StatelessWidget {
  const ActivitySourceSelector({
    super.key,
    required this.options,
    required this.selectedIds,
    required this.onToggle,
    this.singleSelection = false,
    this.accent,
  });

  final List<GroupActivitySourceOption> options;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool singleSelection;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color color = accent ?? context.colorTokens.primary;
    return CreationConfigCard(
      accent: color,
      header: CreationSectionHeader(
        icon: Icons.link_rounded,
        label: context.l10n.groupLinksTitle,
        accent: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (options.isEmpty)
            Text(
              singleSelection
                  ? context.l10n.groupLinksEmptyGoals
                  : context.l10n.groupLinksEmpty,
              style: context.textStyles.caption,
            )
          else ...[
            Text(
              singleSelection
                  ? context.l10n.groupLinksSelectedGoal(selectedIds.length)
                  : context.l10n.groupLinksSelected(selectedIds.length),
              style: context.textStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(AppSpacing.betweenRelated),
            for (final option in options) ...[
              _SourceTile(
                key: ValueKey('source_${option.id}'),
                name: option.name,
                selected: selectedIds.contains(option.id),
                singleSelection: singleSelection,
                accent: color,
                onTap: () => onToggle(option.id),
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
                  child: Text(
                    context.l10n.groupLinksExplanation,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                      height: 1.4,
                    ),
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

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    super.key,
    required this.name,
    required this.selected,
    required this.singleSelection,
    required this.accent,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final bool singleSelection;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IconData icon = singleSelection
        ? (selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded)
        : (selected
              ? Icons.check_box_rounded
              : Icons.check_box_outline_blank_rounded);

    return Semantics(
      button: true,
      checked: selected,
      inMutuallyExclusiveGroup: singleSelection,
      child: BounceTap(
        behavior: HitTestBehavior.opaque,
        pressedScale: 0.98,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.08)
                : context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.5)
                  : context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: selected ? accent : context.colorTokens.borderUnfocused,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
