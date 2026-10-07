import "package:flutter/material.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

class ActivitySourceSelector extends StatelessWidget {
  const ActivitySourceSelector({
    super.key,
    required this.useExisting,
    required this.options,
    required this.selectedIds,
    required this.onModeChanged,
    required this.onToggle,
    this.isReading = false,
  });

  final bool useExisting;
  final List<GroupActivitySourceOption> options;
  final Set<String> selectedIds;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<String> onToggle;
  final bool isReading;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.groupLinksTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(context.l10n.groupLinksUseExisting),
                selected: useExisting,
                onSelected: (_) => onModeChanged(true),
              ),
              ChoiceChip(
                label: Text(context.l10n.groupLinksCreateNew),
                selected: !useExisting,
                onSelected: (_) => onModeChanged(false),
              ),
            ],
          ),
          if (useExisting) ...[
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(context.l10n.groupLinksEmpty),
              ),
            for (final option in options)
              CheckboxListTile(
                key: ValueKey('source_${option.id}'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(option.name),
                value: selectedIds.contains(option.id),
                onChanged: (_) => onToggle(option.id),
              ),
            Text(context.l10n.groupLinksSelected(selectedIds.length)),
          ],
          const SizedBox(height: 12),
          Text(context.l10n.groupLinksExplanation),
          if (isReading) ...[
            const SizedBox(height: 8),
            Text(context.l10n.groupLinksReadingHint),
          ],
        ],
      ),
    ),
  );
}
