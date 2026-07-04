import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({required this.rank, required this.member, required this.seconds, super.key});

  final int rank;
  final GroupMemberEntity member;
  final int seconds;

  static const List<Color> _medalColors = [Color(0xFFFFC107), Color(0xFFB0BEC5), Color(0xFFD08A55)];

  @override
  Widget build(BuildContext context) {
    final bool isTopThree = rank <= 3;
    final Color avatarColor = Color(member.avatarColorValue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: isTopThree ? Border.all(color: _medalColors[rank - 1].withValues(alpha: 0.6), width: 1.5) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              "$rank",
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                color: isTopThree ? _medalColors[rank - 1] : context.colorTokens.textHint,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withValues(alpha: 0.2),
            backgroundImage: NetworkImage(member.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(member.name, style: context.textStyles.bodyLarge)),
          Text(
            formatDurationLong(Duration(seconds: seconds)),
            style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint),
          ),
        ],
      ),
    );
  }
}
