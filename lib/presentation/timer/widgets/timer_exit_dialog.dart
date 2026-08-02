import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

Future<bool?> showTimerExitDialog({
  required BuildContext context,
  required Color accentColor,
  required String title,
  required String content,
  required String cancelLabel,
  required String confirmLabel,
}) => appNavigator.dialog<bool>(
  child: _TimerExitDialog(
    accentColor: accentColor,
    title: title,
    content: content,
    cancelLabel: cancelLabel,
    confirmLabel: confirmLabel,
  ),
);

Future<int?> showReadingExitDialog({
  required BuildContext context,
  required Color accentColor,
  required String title,
  required String content,
  required String cancelLabel,
  required String confirmLabel,
}) => appNavigator.dialog<int>(
  child: _ReadingExitDialog(
    accentColor: accentColor,
    title: title,
    content: content,
    cancelLabel: cancelLabel,
    confirmLabel: confirmLabel,
  ),
);

class _TimerExitDialog extends StatelessWidget {
  const _TimerExitDialog({
    required this.accentColor,
    required this.title,
    required this.content,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final Color accentColor;
  final String title;
  final String content;
  final String cancelLabel;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) => Dialog(
    elevation: 0,
    backgroundColor: context.colorTokens.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(Icons.logout_rounded, color: accentColor, size: 38),
              ),
            ),
            const Gap(24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colorTokens.dialogText,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
            const Gap(18),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colorTokens.dialogTextMuted,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const Gap(12),
            Text(
              context.l10n.timerExitDialogContinueLater,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colorTokens.textHint,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const Gap(24),
            Divider(color: context.colorTokens.divider),
            const Gap(22),
            // Staying in the session is the safe, common choice, so it carries
            // the primary weight and ending is the secondary action.
            _TimerExitDialogButton(
              label: cancelLabel,
              textColor: context.colorTokens.white,
              backgroundColor: accentColor,
              onTap: () => appNavigator.back<bool>(result: false),
            ),
            const Gap(12),
            _TimerExitDialogButton(
              label: confirmLabel,
              textColor: context.colorTokens.dialogTextMuted,
              borderColor: context.colorTokens.borderFocused,
              onTap: () => appNavigator.back<bool>(result: true),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReadingExitDialog extends StatefulWidget {
  const _ReadingExitDialog({
    required this.accentColor,
    required this.title,
    required this.content,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final Color accentColor;
  final String title;
  final String content;
  final String cancelLabel;
  final String confirmLabel;

  @override
  State<_ReadingExitDialog> createState() => _ReadingExitDialogState();
}

class _ReadingExitDialogState extends State<_ReadingExitDialog> {
  final TextEditingController _pagesController = TextEditingController();

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    elevation: 0,
    backgroundColor: context.colorTokens.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: widget.accentColor,
                  size: 38,
                ),
              ),
            ),
            const Gap(24),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colorTokens.dialogText,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
            const Gap(18),
            Text(
              widget.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colorTokens.dialogTextMuted,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const Gap(18),
            TextField(
              controller: _pagesController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colorTokens.dialogText,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.pagesReadNowHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.colorTokens.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: widget.accentColor, width: 2),
                ),
              ),
            ),
            const Gap(24),
            Divider(color: context.colorTokens.divider),
            const Gap(22),
            _TimerExitDialogButton(
              label: widget.cancelLabel,
              textColor: context.colorTokens.white,
              backgroundColor: widget.accentColor,
              onTap: () => appNavigator.back<int>(),
            ),
            const Gap(12),
            _TimerExitDialogButton(
              label: widget.confirmLabel,
              textColor: context.colorTokens.dialogTextMuted,
              borderColor: context.colorTokens.borderFocused,
              onTap: () => appNavigator.back<int>(
                result: int.tryParse(_pagesController.text.trim()) ?? 0,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TimerExitDialogButton extends StatelessWidget {
  const _TimerExitDialogButton({
    required this.label,
    required this.textColor,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  final String label;
  final Color textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorTokens.transparent,
        borderRadius: BorderRadius.circular(14),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
