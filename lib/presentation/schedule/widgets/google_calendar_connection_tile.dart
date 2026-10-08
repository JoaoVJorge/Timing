import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/core/services/google_calendar/google_calendar_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

import "package:timing/theme/app_spacing.dart";

class GoogleCalendarConnectionButton extends StatelessWidget {
  const GoogleCalendarConnectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GoogleCalendarService>()) {
      return const SizedBox.shrink();
    }
    final service = Get.find<GoogleCalendarService>();
    return Obx(() {
      final bool needsAttention =
          !service.connected.value ||
          service.needsReconnect.value ||
          service.errorCode.value.isNotEmpty;
      final Color color = needsAttention
          ? context.colorTokens.error
          : context.colorTokens.primary;
      return IconButton(
        tooltip: needsAttention
            ? "Google Calendar · ${service.needsReconnect.value
                  ? context.l10n.googleCalendarReconnect
                  : service.errorCode.value.isNotEmpty
                  ? context.l10n.googleCalendarError
                  : context.l10n.googleCalendarConnect}"
            : context.l10n.googleCalendarActions,
        style: IconButton.styleFrom(
          foregroundColor: color,
          backgroundColor: needsAttention ? color.withValues(alpha: 0.1) : null,
          minimumSize: const Size(48, 48),
        ),
        icon: Icon(
          needsAttention
              ? Icons.error_outline_rounded
              : Icons.event_available_rounded,
          size: 24,
        ),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => _GoogleCalendarConnectionDialog(service: service),
        ),
      );
    });
  }
}

class _GoogleCalendarConnectionDialog extends StatelessWidget {
  const _GoogleCalendarConnectionDialog({required this.service});

  final GoogleCalendarService service;

  @override
  Widget build(BuildContext context) => Obx(() {
    final l10n = context.l10n;
    final bool needsConnection =
        !service.connected.value || service.needsReconnect.value;
    final bool hasError = service.errorCode.value.isNotEmpty;
    final bool busy = service.busy.value;
    final String message = service.errorCode.value == "function_unavailable"
        ? l10n.googleCalendarUnavailable
        : service.connecting.value
        ? l10n.googleCalendarConnecting
        : service.needsReconnect.value
        ? l10n.googleCalendarReconnect
        : hasError
        ? l10n.googleCalendarError
        : service.connected.value
        ? service.pending.value
              ? l10n.googleCalendarPending
              : l10n.googleCalendarConnected(service.timeZone.value)
        : l10n.googleCalendarDescription;
    final Color iconColor = needsConnection || hasError
        ? context.colorTokens.error
        : context.colorTokens.primary;
    return Dialog(
      elevation: 0,
      backgroundColor: context.colorTokens.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
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
        child: SingleChildScrollView(
          padding: AppSpacing.confirmationDialog,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    needsConnection || hasError
                        ? Icons.error_outline_rounded
                        : Icons.event_available_rounded,
                    color: context.colorTokens.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Google Calendar",
                textAlign: TextAlign.center,
                style: context.textStyles.dialogTitle,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.textStyles.dialogBody,
              ),
              if (busy) ...[
                const SizedBox(height: 20),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        foregroundColor: context.colorTokens.primary,
                        side: BorderSide(color: context.colorTokens.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        MaterialLocalizations.of(context).closeButtonLabel,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        backgroundColor: context.colorTokens.primary,
                        foregroundColor: context.colorTokens.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: busy
                          ? null
                          : needsConnection
                          ? service.connect
                          : service.sync,
                      child: Text(
                        needsConnection
                            ? l10n.googleCalendarConnect
                            : l10n.googleCalendarSync,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              if (service.connected.value) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: busy ? null : service.disconnect,
                  child: Text(l10n.googleCalendarDisconnect),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  });
}
