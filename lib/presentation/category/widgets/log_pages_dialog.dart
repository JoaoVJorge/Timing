import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/dialog_top_bar.dart";
import "package:help_out/shared/widgets/floating_primary_button.dart";
import "package:help_out/theme/decoration.dart";

class LogPagesDialog extends StatefulWidget {
  const LogPagesDialog({required this.subject, super.key});

  final SubjectEntity subject;

  @override
  State<LogPagesDialog> createState() => _LogPagesDialogState();
}

class _LogPagesDialogState extends State<LogPagesDialog> {
  final TextEditingController _pagesController = TextEditingController();

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final int pagesRead = int.tryParse(_pagesController.text.trim()) ?? 0;
    if (pagesRead <= 0) {
      return;
    }
    appNavigator.back<int>(result: widget.subject.currentPages + pagesRead);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: DialogTopBar(title: widget.subject.name),

    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.subject.goalPages > 0
              ? context.l10n.pagesProgress(
                  widget.subject.currentPages,
                  widget.subject.goalPages,
                )
              : context.l10n.pagesReadOnly(widget.subject.currentPages),
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
        const Gap(16),
        TextField(
          controller: _pagesController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: AppInputDecoration.withBorder(
            tokens: context.colorTokens,
            hintText: context.l10n.pagesReadNowHint,
          ),
        ),
      ],
    ),
    actions: [
      FloatingPrimaryButton(
        label: context.l10n.logPagesButton,
        onTap: _onSubmit,
      ),
    ],
  );
}
