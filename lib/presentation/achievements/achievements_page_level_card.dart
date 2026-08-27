part of "achievements_page.dart";

class _UnlockedSummary extends StatelessWidget {
  const _UnlockedSummary({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "${controller.unlockedCount}",
            style: TextStyle(
              color: context.colorTokens.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: context.l10n.achievementsUnlockedSuffix,
            style: TextStyle(color: context.colorTokens.textHint),
          ),
        ],
      ),
      style: context.textStyles.bodyMedium.copyWith(fontSize: 15),
    ),
  );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final AchievementDefinition? nextUnlock = controller.nextUnlock;
    final RankTier tier = controller.currentTier;

    return BounceTap(
      pressedScale: 0.98,
      onTap: () => _showRanksSheet(context, controller),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(context, radius: 22),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tier.color.withValues(alpha: 0.16),
                  ),
                  child: Icon(tier.icon, color: tier.color, size: 36),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.currentLevelLabel,
                              style: context.textStyles.bodySmall.copyWith(
                                color: context.colorTokens.textHint,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: context.colorTokens.textHint,
                            size: 20,
                          ),
                        ],
                      ),
                      const Gap(2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tier.learnerLabel(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.extraBold20.copyWith(
                                color: context.colorTokens.textBody,
                              ),
                            ),
                          ),
                          const Gap(6),
                          _LevelPill(level: controller.level),
                        ],
                      ),
                      const Gap(8),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "${controller.levelXp}",
                              style: TextStyle(
                                color: context.colorTokens.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: " / 800 XP",
                              style: TextStyle(
                                color: context.colorTokens.textHint,
                              ),
                            ),
                          ],
                        ),
                        style: context.textStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: controller.levelProgress,
                          backgroundColor: context.colorTokens.primaryVeryLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.colorTokens.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            Divider(color: context.colorTokens.divider),
            const Gap(10),
            Row(
              children: [
                _SmallBadge(
                  icon: nextUnlock?.icon ?? Icons.done_all_rounded,
                  color: nextUnlock?.color ?? context.colorTokens.success,
                  isUnlocked: true,
                  size: 38,
                  iconSize: 19,
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextUnlock == null
                            ? context.l10n.allAchievementsUnlockedLabel
                            : context.l10n.nextUnlockLabel,
                        style: context.textStyles.bodyTiny.copyWith(
                          color: context.colorTokens.textHint,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        nextUnlock?.title ?? context.l10n.achievement50Title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        nextUnlock?.description ??
                            context.l10n.allAchievementsUnlockedDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyTiny.copyWith(
                          color: context.colorTokens.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: context.colorTokens.borderUnfocused,
                    ),
                  ),
                  child: Text(
                    context.l10n.xpToGo(800 - controller.levelXp),
                    style: context.textStyles.bodyTiny.copyWith(
                      color: context.colorTokens.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  });
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      context.l10n.levelLabel(level),
      style: context.textStyles.bodyTiny.copyWith(
        color: context.colorTokens.primary,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
