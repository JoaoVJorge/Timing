import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/friends/widgets/friends_shared.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class FriendsInviteCodeDisclosure extends StatefulWidget {
  const FriendsInviteCodeDisclosure({
    required this.code,
    required this.onCopy,
    required this.onShare,
    super.key,
  });

  final String code;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  State<FriendsInviteCodeDisclosure> createState() =>
      _FriendsInviteCodeDisclosureState();
}

class _FriendsInviteCodeDisclosureState
    extends State<FriendsInviteCodeDisclosure> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) => Container(
    decoration: friendsSurfaceDecoration(context, radius: 18),
    child: AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          BounceTap(
            onTap: () => setState(() => isExpanded = !isExpanded),
            pressedScale: 0.98,
            child: SizedBox(
              height: 46,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_rounded,
                      color: context.colorTokens.primary,
                      size: 21,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        _label(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.cardTitle.copyWith(),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.colorTokens.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isExpanded
                ? Column(
                    key: const ValueKey("invite-code-open"),
                    children: [
                      Divider(
                        height: 1,
                        indent: 14,
                        endIndent: 14,
                        color: context.colorTokens.divider,
                      ),
                      _InviteCodeCard(
                        code: widget.code,
                        onCopy: widget.onCopy,
                        onShare: widget.onShare,
                      ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey("invite-code-closed")),
          ),
        ],
      ),
    ),
  );

  String _label(BuildContext context) => switch (context.languageCode) {
    "es" => "Mi código",
    "pt" => "Meu código",
    _ => "My code",
  };
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({
    required this.code,
    required this.onCopy,
    required this.onShare,
  });

  final String code;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
    child: Row(
      children: [
        const FriendsPinkBadge(
          icon: Icons.qr_code_rounded,
          size: 46,
          iconSize: 24,
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _label(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.textHint,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(2),
              Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black20.copyWith(
                  color: context.colorTokens.primary,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        BounceTap(
          onTap: onCopy,
          pressedScale: 0.95,
          child: const _InviteIconButton(icon: Icons.copy_rounded),
        ),
        const Gap(8),
        BounceTap(
          onTap: onShare,
          pressedScale: 0.95,
          child: const _InviteIconButton(icon: Icons.share_rounded),
        ),
      ],
    ),
  );

  String _label(BuildContext context) => switch (context.languageCode) {
    "es" => "Tu código de invitación",
    "pt" => "Seu código de convite",
    _ => "Your invite code",
  };
}

class _InviteIconButton extends StatelessWidget {
  const _InviteIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      shape: BoxShape.circle,
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Icon(icon, color: context.colorTokens.primary, size: 20),
  );
}
