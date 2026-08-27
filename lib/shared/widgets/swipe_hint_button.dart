import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

class SwipeHintButton extends StatelessWidget {
  const SwipeHintButton({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: title,
    child: Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showHint(context),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(
              Icons.info_outline_rounded,
              size: 28,
              color: context.colorTokens.primary,
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _showHint(BuildContext context) => appNavigator.dialog<void>(
    child: _SwipeHintDialog(
      title: title,
      message: message,
      accentColor: context.colorTokens.primary,
    ),
  );
}

class _SwipeHintDialog extends StatelessWidget {
  const _SwipeHintDialog({
    required this.title,
    required this.message,
    required this.accentColor,
  });

  final String title;
  final String message;
  final Color accentColor;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.12),
              border: Border.all(color: accentColor.withValues(alpha: 0.14)),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: accentColor,
              size: 40,
            ),
          ),
          const Gap(22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorTokens.dialogText,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const Gap(14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorTokens.dialogTextMuted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const Gap(24),
          _SwipeHintDialogButton(
            label: "Entendi",
            textColor: context.colorTokens.white,
            backgroundColor: accentColor,
            onTap: () => appNavigator.back<void>(),
          ),
        ],
      ),
    ),
  );
}

class _SwipeHintDialogButton extends StatelessWidget {
  const _SwipeHintDialogButton({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
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
