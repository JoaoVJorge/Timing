import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

Future<bool> showDeleteConfirmationDialog({
  required String itemName,
  String? itemTypeName,
}) async {
  final bool? confirmed = await appNavigator.dialog<bool>(
    child: DeleteConfirmationDialog(
      itemName: itemName,
      itemTypeName: itemTypeName,
    ),
  );
  return confirmed ?? false;
}

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    required this.itemName,
    this.itemTypeName,
    super.key,
  });

  final String itemName;
  final String? itemTypeName;

  @override
  Widget build(BuildContext context) {
    final Color danger = context.colorTokens.error;
    final Color accent = context.colorTokens.primary;

    return Dialog(
      elevation: 0,
      backgroundColor: context.colorTokens.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 34),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          color: context.colorTokens.dialogSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.black.withValues(alpha: 0.16),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: danger,
                size: 28,
              ),
            ),
            const Gap(12),
            Text(
              _title(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textStyles.extraBold24.copyWith(
                color: context.colorTokens.dialogText,
                fontSize: 21,
                height: 1.12,
              ),
            ),
            const Gap(20),
            Text(
              _content(context),
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.dialogTextMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.38,
              ),
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, color: accent, size: 26),
                  const Gap(12),
                  Flexible(
                    child: Text(
                      _historyWarning(context),
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: context.colorTokens.dialogTextMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: _DeleteDialogButton(
                    label: context.l10n.cancelButton,
                    foreground: accent,
                    borderColor: accent,
                    onTap: () => appNavigator.back<bool>(result: false),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _DeleteDialogButton(
                    label: _confirmLabel(context),
                    foreground: context.colorTokens.white,
                    gradient: LinearGradient(
                      colors: [
                        danger,
                        Color.lerp(danger, Colors.redAccent, 0.35) ?? danger,
                      ],
                    ),
                    onTap: () => appNavigator.back<bool>(result: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _typeName(BuildContext context) =>
      itemTypeName ??
      switch (context.languageCode) {
        "en" => "item",
        "es" => "elemento",
        _ => "item",
      };

  String _title(BuildContext context) => switch (context.languageCode) {
    "en" => "Delete ${_typeName(context)}?",
    "es" => "¿Eliminar ${_typeName(context)}?",
    _ => "Excluir ${_typeName(context)}?",
  };

  String _content(BuildContext context) => switch (context.languageCode) {
    "en" =>
      "You are about to delete \"$itemName\". This action cannot be undone.",
    "es" =>
      "Estás por eliminar \"$itemName\". Esta acción no se puede deshacer.",
    _ =>
      "Você está prestes a excluir \"$itemName\". Esta ação não poderá ser desfeita.",
  };

  String _historyWarning(BuildContext context) =>
      switch (context.languageCode) {
        "en" => "This ${_typeName(context)} history will also be removed.",
        "es" =>
          "El historial de este ${_typeName(context)} también se eliminará.",
        _ => "O histórico deste ${_typeName(context)} também será removido.",
      };

  String _confirmLabel(BuildContext context) => switch (context.languageCode) {
    "en" => "Delete",
    "es" => "Eliminar",
    _ => "Excluir",
  };
}

class _DeleteDialogButton extends StatelessWidget {
  const _DeleteDialogButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.borderColor,
    this.gradient,
  });

  final String label;
  final Color foreground;
  final VoidCallback onTap;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyLarge.copyWith(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
