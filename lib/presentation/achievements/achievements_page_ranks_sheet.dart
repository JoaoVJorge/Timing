part of "achievements_page.dart";

class _RanksSheet extends StatelessWidget {
  const _RanksSheet({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) {
    final int level = controller.level;
    final RankTier currentTier = controller.currentTier;

    return SafeArea(
      child: Padding(
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
                _RanksHeroBadge(tier: currentTier),
                const Gap(18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.allLevelsTitle,
                        style: context.textStyles.extraBold24.copyWith(
                          color: context.colorTokens.textBody,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        context.l10n.allLevelsDescription,
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
              context.l10n.currentLevelLabel,
              style: context.textStyles.sectionTitle.copyWith(
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final RankTier tier in RankTier.values) ...[
                    _RankRow(
                      tier: tier,
                      isCurrent: tier == currentTier,
                      isUnlocked: level >= tier.minLevel,
                    ),
                    if (tier != RankTier.values.last) const Gap(10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RanksHeroBadge extends StatelessWidget {
  const _RanksHeroBadge({required this.tier});

  final RankTier tier;

  @override
  Widget build(BuildContext context) => Container(
    width: 92,
    height: 92,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: tier.color.withValues(alpha: 0.12),
      border: Border.all(color: tier.color.withValues(alpha: 0.16)),
    ),
    child: Center(
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tier.color.withValues(alpha: 0.12),
        ),
        child: Icon(tier.icon, color: tier.color, size: 38),
      ),
    ),
  );
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.tier,
    required this.isCurrent,
    required this.isUnlocked,
  });

  final RankTier tier;
  final bool isCurrent;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final Color color = isUnlocked
        ? tier.color
        : context.colorTokens.iconDisabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? tier.color.withValues(alpha: 0.10)
            : context.colorTokens.surfaceInnerLayer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? tier.color.withValues(alpha: 0.6)
              : context.colorTokens.borderUnfocused,
          width: isCurrent ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(tier.icon, color: color, size: 21),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.label(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  context.l10n.levelPlusLabel(tier.minLevel),
                  style: context.textStyles.bodyTiny.copyWith(
                    color: context.colorTokens.textHint,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tier.color,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                context.l10n.currentLabel,
                style: context.textStyles.bodyTiny.copyWith(
                  color: context.colorTokens.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else
            Icon(
              isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
              color: isUnlocked
                  ? tier.color
                  : context.colorTokens.borderUnfocused,
              size: 22,
            ),
        ],
      ),
    );
  }
}
