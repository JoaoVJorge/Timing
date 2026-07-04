import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
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

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: context.colorTokens.primary, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              "https://i.pravatar.cc/150?u=${friend.id}",
            ),
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
