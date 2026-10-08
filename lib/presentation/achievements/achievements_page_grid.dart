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

  final AchievementDefinition achievement;

  @override
  Widget build(BuildContext context) {
    final metrics = _AchievementCardMetrics(context);
    final Color effectiveColor = achievement.isUnlocked
        ? achievement.color
        : context.colorTokens.iconDisabled;

    return BounceTap(
      onTap: () => _showAchievementDetailsDialog(context, achievement),
      pressedScale: 0.97,
      child: Container(
        height: metrics.height,
        padding: const EdgeInsets.all(10),
        decoration: _cardDecoration(context, radius: 12),
        child: Column(
          children: [
            _SmallBadge(
              icon: achievement.icon,
              color: effectiveColor,
              isUnlocked: achievement.isUnlocked,
              size: 34,
              iconSize: 18,
            ),
            const Gap(8),
            SizedBox(
              height: metrics.titleHeight,
              width: double.infinity,
              child: Text(
                achievement.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: metrics.titleStyle,
                strutStyle: StrutStyle.fromTextStyle(
                  metrics.titleStyle,
                  forceStrutHeight: true,
                ),
              ),
            ),
            const Gap(4),
            SizedBox(
              height: metrics.descriptionHeight,
              width: double.infinity,
              child: Text(
                achievement.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: metrics.descriptionStyle,
                strutStyle: StrutStyle.fromTextStyle(
                  metrics.descriptionStyle,
                  forceStrutHeight: true,
                ),
              ),
            ),
            const Gap(8),
            const Spacer(),
            _StatusBadge(isUnlocked: achievement.isUnlocked),
          ],
        ),
      ),
    );
  }
}

/// Reserve the same text slots in every card, including at larger system fonts.
class _AchievementCardMetrics {
  _AchievementCardMetrics(BuildContext context) {
    titleStyle = DefaultTextStyle.of(context).style.merge(
      context.textStyles.bodyTiny.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        height: 1.08,
      ),
    );
    descriptionStyle = DefaultTextStyle.of(context).style.merge(
      context.textStyles.bodyTiny.copyWith(
        color: context.colorTokens.textHint,
        height: 1.1,
      ),
    );
    double lineHeight(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: "Ag", style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
      )..layout();
      final height = painter.height.ceilToDouble();
      painter.dispose();
      return height;
    }

    titleHeight = lineHeight(titleStyle);
    descriptionHeight = lineHeight(descriptionStyle) * 2;
  }

  late final TextStyle titleStyle;
  late final TextStyle descriptionStyle;
  late final double titleHeight;
  late final double descriptionHeight;

  // Padding + border, badge, gaps, and status indicator stay fixed.
  double get height =>
      (22 + 34 + 8 + titleHeight + 4 + descriptionHeight + 8 + 18).clamp(
        130.0,
        double.infinity,
      );
}

class _AchievementInfoPill extends StatelessWidget {
  const _AchievementInfoPill({
    required this.label,
    required this.icon,
    required this.color,
    this.emphasizeIcon = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool emphasizeIcon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: emphasizeIcon
          ? color.withValues(alpha: 0.10)
          : context.colorTokens.surfaceInnerLayer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: emphasizeIcon
              ? BoxDecoration(color: color, shape: BoxShape.circle)
              : null,
          child: Icon(
            icon,
            color: emphasizeIcon ? context.colorTokens.white : color,
            size: 15,
          ),
        ),
        const Gap(8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.dialogTextMuted,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
  const _StatusBadge({required this.isUnlocked});

  final bool isUnlocked;

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isUnlocked
          ? context.colorTokens.primary
          : context.colorTokens.borderUnfocused,
    ),
    child: Icon(
      isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
      color: context.colorTokens.white,
      size: 12,
    ),
  );
}
