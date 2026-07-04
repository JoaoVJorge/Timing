import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/floating_primary_button.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";

typedef AddSubjectResult = ({
  String name,
  int colorValue,
  int goalSeconds,
  int goalPages,
});

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({required this.category, super.key});

  final TimeCategoryType category;

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  Color _selectedColor = SubjectColors.values.first;

  bool get _isPageBased => widget.category == TimeCategoryType.reading;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    if (_isPageBased) {
      final int goalPages = int.tryParse(_goalController.text.trim()) ?? 0;
      appNavigator.back<AddSubjectResult>(
        result: (
          name: name,
          colorValue: _selectedColor.toARGB32(),
          goalSeconds: 0,
          goalPages: goalPages,
        ),
      );
      return;
    }

    final double goalHours = double.tryParse(_goalController.text.trim()) ?? 0;
    appNavigator.back<AddSubjectResult>(
      result: (
        name: name,
        colorValue: _selectedColor.toARGB32(),
        goalSeconds: (goalHours * 3600).round(),
        goalPages: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.addItemButton(widget.category.itemNoun(context))),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: context.l10n.itemNameHint(
                widget.category.itemNoun(context),
              ),
            ),
          ),
          const Gap(16),
          Text(
            _isPageBased
                ? context.l10n.bookThemeLabel
                : context.l10n.colorLabel,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textHint,
            ),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SubjectColors.values.map((color) {
              final bool isSelected =
                  color.toARGB32() == _selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: context.colorTokens.textBody,
                            width: 2,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: AppIcon(
                            "check",
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const Gap(16),
          TextField(
            controller: _goalController,
            keyboardType: _isPageBased
                ? TextInputType.number
                : const TextInputType.numberWithOptions(decimal: true),
            decoration: AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: _isPageBased
                  ? context.l10n.goalPagesHint
                  : context.l10n.estimatedHoursGoalHint,
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => appNavigator.back<AddSubjectResult>(),
        child: Text(context.l10n.cancelButton),
      ),
      const SizedBox(width: 4),
      FloatingPrimaryButton(label: context.l10n.addButton, onTap: _onSubmit),
    ],
  );
}
