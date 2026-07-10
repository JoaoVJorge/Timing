import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class FriendTile extends StatelessWidget {
  const FriendTile({
    required this.friend,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final FriendOption friend;
  final bool isSelected;
  final VoidCallback onTap;

  static const List<int> _avatarColors = [
    0xFFE0507A,
    0xFF2E6ADE,
    0xFF3FA65D,
    0xFF8325FF,
    0xFF1FA2A6,
    0xFFFF7A30,
  ];

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          GroupMemberAvatar(
            name: friend.name,
            colorValue:
                _avatarColors[friend.id.hashCode.abs() % _avatarColors.length],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge,
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? context.colorTokens.primary
                  : Colors.transparent,
              border: isSelected
                  ? null
                  : Border.all(
                      color: context.colorTokens.borderUnfocused,
                      width: 1.5,
                    ),
            ),
            child: isSelected
                ? const Center(
                    child: AppIcon("check", size: 12, color: Colors.white),
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}
