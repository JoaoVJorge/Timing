import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/floating_primary_button.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";

typedef AddScheduleEntryResult = ({
  String title,
  int startMinutes,
  int? endMinutes,
  int colorValue,
});

class AddScheduleEntryDialog extends StatefulWidget {
  const AddScheduleEntryDialog({super.key});

  @override
  State<AddScheduleEntryDialog> createState() => _AddScheduleEntryDialogState();
}

class _AddScheduleEntryDialogState extends State<AddScheduleEntryDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final FocusNode _startTimeFocusNode = FocusNode();
  final FocusNode _endTimeFocusNode = FocusNode();
  Color _selectedColor = SubjectColors.values.first;

  @override
  void dispose() {
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _startTimeFocusNode.dispose();
    _endTimeFocusNode.dispose();
    super.dispose();
  }

  static ({int hour, int minute})? _parseTime(String raw) {
    final RegExpMatch? match = RegExp(
      r"^([0-9]{1,2}):([0-9]{1,2})$",
    ).firstMatch(raw.trim());
    if (match == null) {
      return null;
    }

    final int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) {
      return null;
    }

    return (hour: hour, minute: minute);
  }

  void _onSubmit() {
    final String title = _titleController.text.trim();
    final ({int hour, int minute})? startTime = _parseTime(
      _startTimeController.text,
    );
    final bool hasEndInput = _endTimeController.text.trim().isNotEmpty;
    final ({int hour, int minute})? endTime = hasEndInput
        ? _parseTime(_endTimeController.text)
        : null;

    final bool isIncomplete =
        title.isEmpty || startTime == null || (hasEndInput && endTime == null);
    if (isIncomplete) {
      appNavigator.showErrorSnackBar(context.l10n.incompleteScheduleEntryError);
      return;
    }

    appNavigator.back<AddScheduleEntryResult>(
      result: (
        title: title,
        startMinutes: startTime.hour * 60 + startTime.minute,
        endMinutes: endTime == null ? null : endTime.hour * 60 + endTime.minute,
        colorValue: _selectedColor.toARGB32(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.addScheduleEntryTitle),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: context.l10n.scheduleTitleHint,
            ),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _TimeTextField(
                  label: context.l10n.startTimeLabel,
                  controller: _startTimeController,
                  focusNode: _startTimeFocusNode,
                  onCompleted: () =>
                      FocusScope.of(context).requestFocus(_endTimeFocusNode),
                ),
              ),
              const Gap(12),
              Expanded(
                child: _TimeTextField(
                  label: context.l10n.endTimeOptionalLabel,
                  controller: _endTimeController,
                  focusNode: _endTimeFocusNode,
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            context.l10n.colorLabel,
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
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => appNavigator.back<AddScheduleEntryResult>(),
        child: Text(context.l10n.cancelButton),
      ),
      const SizedBox(width: 4),
      FloatingPrimaryButton(label: context.l10n.addButton, onTap: _onSubmit),
    ],
  );
}

/// Runs after [FilteringTextInputFormatter.digitsOnly], so [newValue] is always pure digits here.
class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.length > 4
        ? newValue.text.substring(0, 4)
        : newValue.text;
    final String formatted = digits.length <= 2
        ? digits
        : "${digits.substring(0, 2)}:${digits.substring(2)}";

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _TimeTextField extends StatelessWidget {
  const _TimeTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.onCompleted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.textHint,
        ),
      ),
      const Gap(6),
      TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _TimeInputFormatter(),
        ],
        onChanged: (value) {
          if (value.length == 5) {
            onCompleted?.call();
          }
        },
        decoration: AppInputDecoration.withBorder(
          tokens: context.colorTokens,
          hintText: "00:00",
        ),
      ),
    ],
  );
}
