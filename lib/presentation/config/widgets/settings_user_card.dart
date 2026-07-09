import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/avatar_presets.dart";

class SettingsUserCard extends StatelessWidget {
  const SettingsUserCard({
    required this.name,
    required this.nickname,
    required this.avatarIconIndex,
    required this.onTap,
    super.key,
  });

  final String name;
  final String nickname;
  final int avatarIconIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: context.colorTokens.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppAvatarPresets.byIndex(avatarIconIndex),
              color: Colors.white,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.accountSection,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.extraBold20,
                ),
                const Gap(4),
                Text(
                  context.l10n.accountDataSubtitle(nickname),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colorTokens.textHint,
          ),
        ],
      ),
    ),
  );
}
