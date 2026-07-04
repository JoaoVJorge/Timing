import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";

typedef AddScheduleEntryResult = ({String title, int startMinutes, int? endMinutes, int colorValue});

class AddScheduleEntryDialog extends StatefulWidget {
  const AddScheduleEntryDialog({super.key});

  @override
  State<AddScheduleEntryDialog> createState() => _AddScheduleEntryDialogState();
}

class _AddScheduleEntryDialogState extends State<AddScheduleEntryDialog> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Color _selectedColor = SubjectColors.values.first;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _startTime ?? TimeOfDay.now());
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _endTime ?? TimeOfDay.now());
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _onSubmit() {
    final String title = _titleController.text.trim();
    if (title.isEmpty || _startTime == null) {
      return;
    }

    appNavigator.back<AddScheduleEntryResult>(
      result: (
        title: title,
        startMinutes: _startTime!.hour * 60 + _startTime!.minute,
        endMinutes: _endTime == null ? null : _endTime!.hour * 60 + _endTime!.minute,
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
            decoration: AppInputDecoration.withBorder(tokens: context.colorTokens, hintText: context.l10n.scheduleTitleHint),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: context.l10n.startTimeLabel,
                  time: _startTime,
                  onTap: _pickStartTime,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _TimeField(
                  label: context.l10n.endTimeOptionalLabel,
                  time: _endTime,
                  onTap: _pickEndTime,
                  onClear: _endTime == null ? null : () => setState(() => _endTime = null),
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(context.l10n.colorLabel, style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint)),
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
                  child: isSelected ? const Center(child: AppIcon("check", size: 14, color: Colors.white)) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => appNavigator.back<AddScheduleEntryResult>(), child: Text(context.l10n.cancelButton)),
      const SizedBox(width: 4),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: context.colorTokens.primary),
        onPressed: _onSubmit,
        child: Text(context.l10n.addButton),
      ),
    ],
  );
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.time, required this.onTap, this.onClear});

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint)),
      const Gap(6),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: context.colorTokens.borderUnfocused),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  time?.format(context) ?? "--:--",
                  style: context.textStyles.bodyLarge,
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 16, color: context.colorTokens.textHint),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
