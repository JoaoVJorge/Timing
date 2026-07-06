import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class GroupChip extends StatelessWidget {
  const GroupChip({
    required this.group,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final GroupEntity group;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? context.colorTokens.primaryGradient
            : LinearGradient(
                colors: [
                  context.colorTokens.surface,
                  context.colorTokens.surface,
                ],
              ),
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow,
            blurRadius: 8,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          group.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isSelected
              ? context.textStyles.textPrimaryButton
              : context.textStyles.bodyLarge.copyWith(
                  color: context.colorTokens.textBody,
                ),
        ),
      ),
    ),
  );
}
