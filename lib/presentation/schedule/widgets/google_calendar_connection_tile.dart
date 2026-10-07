import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/core/services/google_calendar/google_calendar_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

class GoogleCalendarConnectionTile extends StatelessWidget {
  const GoogleCalendarConnectionTile({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GoogleCalendarService>()) {
      return const SizedBox.shrink();
    }
    final service = Get.find<GoogleCalendarService>();
    return Obx(() {
      final l10n = context.l10n;
      final subtitle = service.needsReconnect.value
          ? l10n.googleCalendarReconnect
          : service.errorCode.value.isNotEmpty
          ? l10n.googleCalendarError
          : service.connecting.value
          ? l10n.googleCalendarConnecting
          : service.connected.value
          ? service.pending.value
                ? l10n.googleCalendarPending
                : l10n.googleCalendarConnected(service.timeZone.value)
          : l10n.googleCalendarDescription;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.event_available_rounded,
          color: context.colorTokens.primary,
        ),
        title: const Text("Google Calendar"),
        subtitle: Text(subtitle),
        trailing: service.busy.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : service.connected.value
            ? PopupMenuButton<String>(
                tooltip: l10n.googleCalendarActions,
                onSelected: (action) {
                  if (action == "sync") service.sync();
                  if (action == "disconnect") service.disconnect();
                  if (action == "reconnect") service.connect();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: "sync",
                    child: Text(l10n.googleCalendarSync),
                  ),
                  PopupMenuItem(
                    value: "reconnect",
                    child: Text(l10n.googleCalendarConnect),
                  ),
                  PopupMenuItem(
                    value: "disconnect",
                    child: Text(l10n.googleCalendarDisconnect),
                  ),
                ],
              )
            : TextButton(
                onPressed: service.connect,
                child: Text(l10n.googleCalendarConnect),
              ),
      );
    });
  }
}
