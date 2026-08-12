import "package:flutter/material.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/group_colors.dart";

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
            colorValue: GroupAvatarColors.byIndex(friend.id.hashCode),
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
