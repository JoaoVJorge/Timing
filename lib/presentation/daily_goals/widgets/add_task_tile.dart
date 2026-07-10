import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

class AddTaskTile extends StatelessWidget {
  const AddTaskTile({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorTokens.borderUnfocused,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon("plus", size: 16, color: context.colorTokens.primary),
          const Gap(8),
          Flexible(
            child: Text(
              context.l10n.addTaskButton,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textButtonMedium,
            ),
          ),
        ],
      ),
    ),
  );
}
