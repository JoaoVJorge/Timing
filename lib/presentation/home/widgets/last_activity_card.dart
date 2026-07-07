import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/last_activity_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class LastActivityCard extends StatelessWidget {
  const LastActivityCard({required this.lastActivity, super.key});

  final LastActivityEntity? lastActivity;

  String _relativeTime(BuildContext context, DateTime timestamp) {
    final Duration difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return context.l10n.lastActivityJustNow;
    }
    if (difference.inHours < 1) {
      return context.l10n.lastActivityMinutesAgo(difference.inMinutes);
    }
    if (difference.inDays < 1) {
      return context.l10n.lastActivityHoursAgo(difference.inHours);
    }
    return context.l10n.lastActivityDaysAgo(difference.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final LastActivityEntity? activity = lastActivity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorTokens.primaryVeryLight,
            context.colorTokens.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colorTokens.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 20,
              color: context.colorTokens.primary,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.lastActivityLabel,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                  ),
                ),
                const Gap(4),
                Text(
                  activity == null
                      ? context.l10n.lastActivityNone
                      : activity.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (activity != null) ...[
            const Gap(12),
            Text(
              _relativeTime(context, activity.timestamp),
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
