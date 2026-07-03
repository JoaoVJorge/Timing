import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";

typedef AddSubjectResult = ({String name, int colorValue, int goalSeconds});

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({super.key});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalHoursController = TextEditingController();
  Color _selectedColor = SubjectColors.values.first;

  @override
  void dispose() {
    _nameController.dispose();
    _goalHoursController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final double goalHours = double.tryParse(_goalHoursController.text.trim()) ?? 0;
    appNavigator.back<AddSubjectResult>(
      result: (name: name, colorValue: _selectedColor.toARGB32(), goalSeconds: (goalHours * 3600).round()),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text("Add Subject"),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: AppInputDecoration.withBorder(tokens: context.colorTokens, hintText: "Subject name"),
          ),
          const Gap(16),
          Text("Color", style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint)),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SubjectColors.values.map((color) {
              final bool isSelected = color.toARGB32() == _selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: context.colorTokens.textBody, width: 2) : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                ),
              );
            }).toList(),
          ),
          const Gap(16),
          TextField(
            controller: _goalHoursController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: "Estimated hours (goal)",
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => appNavigator.back<AddSubjectResult>(), child: const Text("Cancel")),
      const SizedBox(width: 4),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: context.colorTokens.primary),
        onPressed: _onSubmit,
        child: const Text("Add"),
      ),
    ],
  );
}
