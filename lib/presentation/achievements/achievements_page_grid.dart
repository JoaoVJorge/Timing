part of "achievements_page.dart";

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({required this.achievements});

  final List<AchievementDefinition> achievements;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const double spacing = 8;
      const int columns = 3;
      final double itemWidth =
          (constraints.maxWidth - (spacing * (columns - 1))) / columns;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final AchievementDefinition achievement in achievements)
            SizedBox(
              width: itemWidth,
              child: _AchievementCard(
                key: ValueKey<int>(achievement.id),
                achievement: achievement,
              ),
            ),
        ],
      );
    },
  );
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, super.key});

  static const double _height = 130;

  final AchievementDefinition achievement;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = achievement.isUnlocked
        ? achievement.color
        : context.colorTokens.iconDisabled;

    final TextStyle titleStyle = context.textStyles.bodyTiny.copyWith(
      color: context.colorTokens.textBody,
      fontSize: 11,
      fontWeight: FontWeight.w900,
      height: 1.08,
    );
    final TextStyle descriptionStyle = context.textStyles.bodyTiny.copyWith(
      color: context.colorTokens.textHint,
      height: 1.1,
    );

    return BounceTap(
      onTap: () => _showAchievementDetailsDialog(context, achievement),
      pressedScale: 0.97,
      child: SizedBox(
        height: _height,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          decoration: _cardDecoration(context, radius: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SmallBadge(
                icon: achievement.icon,
                color: effectiveColor,
                isUnlocked: achievement.isUnlocked,
                size: 34,
                iconSize: 18,
              ),
              const Gap(6),
              Text(
                achievement.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              const Gap(3),
              Text(
                achievement.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: descriptionStyle,
              ),
              const Spacer(),
              _StatusBadge(isUnlocked: achievement.isUnlocked),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementInfoPill extends StatelessWidget {
  const _AchievementInfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: context.colorTokens.surfaceInnerLayer,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.bodyTiny.copyWith(
        color: context.colorTokens.textHint,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.icon,
    required this.color,
    required this.isUnlocked,
    this.size = 48,
    this.iconSize = 24,
  });

  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: isUnlocked ? 0.18 : 0.12),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    ),
    child: Icon(icon, color: color, size: iconSize),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isUnlocked,
    this.size = 18,
    this.iconSize = 12,
  });

  final bool isUnlocked;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isUnlocked
          ? context.colorTokens.primary
          : context.colorTokens.borderUnfocused,
    ),
    child: Icon(
      isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
      color: context.colorTokens.white,
      size: iconSize,
    ),
  );
}
