import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class CreateGroupChip extends StatelessWidget {
  const CreateGroupChip({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colorTokens.primary, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 18, color: context.colorTokens.primary),
          const SizedBox(width: 4),
          Text(
            context.l10n.newGroupChip,
            style: context.textStyles.bodyLarge.copyWith(
              color: context.colorTokens.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
