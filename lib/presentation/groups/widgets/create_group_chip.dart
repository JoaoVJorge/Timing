import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class CreateGroupChip extends StatelessWidget {
  const CreateGroupChip({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              size: 20,
              color: context.colorTokens.primary,
            ),
          ),
          const Gap(10),
          Text(
            context.l10n.newGroupChip,
            style: context.textStyles.bodyLarge.copyWith(
              color: context.colorTokens.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}
