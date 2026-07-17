import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class GroupChip extends StatelessWidget {
  const GroupChip({
    required this.group,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final GroupEntity group;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: isSelected
            ? context.colorTokens.primaryGradient
            : LinearGradient(
                colors: [
                  context.colorTokens.surface,
                  context.colorTokens.surface,
                ],
              ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : context.colorTokens.primaryVeryLight,
            ),
            child: Center(
              child: AppIcon(
                group.theme.iconName,
                size: 20,
                color: isSelected ? Colors.white : context.colorTokens.primary,
              ),
            ),
          ),
          const Gap(10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 158),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isSelected
                  ? context.textStyles.textPrimaryButton.copyWith(fontSize: 16)
                  : context.textStyles.bodyLarge.copyWith(
                      color: context.colorTokens.textBody,
                      fontSize: 16,
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}
