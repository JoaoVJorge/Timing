part of "add_schedule_entry_page.dart";

class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector({
    required this.activeFrom,
    required this.activeUntil,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onClearEnd,
  });

  final DateTime activeFrom;
  final DateTime? activeUntil;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onClearEnd;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    return Row(
      children: [
        Expanded(
          child: _DateChip(
            label: context.l10n.scheduleActiveFromLabel,
            value: DateFormat.yMd(locale).format(activeFrom),
            icon: Icons.event_available_rounded,
            onTap: onPickStart,
          ),
        ),
        const Gap(AppSpacing.betweenRelated),
        Expanded(
          child: _DateChip(
            label: context.l10n.scheduleActiveUntilLabel,
            value: activeUntil == null
                ? context.l10n.optionalHint
                : DateFormat.yMd(locale).format(activeUntil!),
            icon: Icons.event_busy_rounded,
            onTap: onPickEnd,
            onClear: activeUntil == null ? null : onClearEnd,
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.98,
    child: Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: context.colorTokens.scaffold.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colorTokens.primary, size: 20),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (onClear != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClear,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.close_rounded,
                  color: context.colorTokens.textHint,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
