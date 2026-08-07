import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class FriendsActivityShortcuts extends StatelessWidget {
  const FriendsActivityShortcuts({
    required this.onPendingTap,
    required this.onSentTap,
    super.key,
  });

  final VoidCallback onPendingTap;
  final VoidCallback onSentTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ShortcutTile(
          icon: Icons.download_rounded,
          title: _pendingLabel(context),
          onTap: onPendingTap,
        ),
      ),
      const Gap(8),
      Expanded(
        child: _ShortcutTile(
          icon: Icons.send_rounded,
          title: _sentLabel(context),
          onTap: onSentTap,
        ),
      ),
    ],
  );

  String _pendingLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Solicitudes",
    "pt" => "Solicitações",
    _ => "Requests",
  };

  String _sentLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Invitaciones",
    "pt" => "Convites",
    _ => "Invites",
  };
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.colorTokens.primary, size: 17),
          const Gap(6),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class AddFriendHeaderButton extends StatelessWidget {
  const AddFriendHeaderButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_add_alt_1_rounded,
        color: context.colorTokens.primary,
        size: 26,
      ),
    ),
  );
}
