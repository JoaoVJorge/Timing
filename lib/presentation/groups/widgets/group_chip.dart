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
        gradient: isSelected ? context.colorTokens.primaryGradient : null,
        color: isSelected ? null : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(24),
        border: isSelected
            ? null
            : Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Text(
        group.name,
        style: isSelected
            ? context.textStyles.textPrimaryButton
            : context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.textBody,
              ),
      ),
    ),
  );
}
