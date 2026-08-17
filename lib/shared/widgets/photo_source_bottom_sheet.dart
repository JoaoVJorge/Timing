import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:image_picker/image_picker.dart";

Future<ImageSource?> showPhotoSourceBottomSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String cameraLabel,
  required String galleryLabel,
}) => showModalBottomSheet<ImageSource>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colorTokens.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
  ),
  builder: (context) => _PhotoSourceBottomSheet(
    title: title,
    subtitle: subtitle,
    cameraLabel: cameraLabel,
    galleryLabel: galleryLabel,
  ),
);

class _PhotoSourceBottomSheet extends StatelessWidget {
  const _PhotoSourceBottomSheet({
    required this.title,
    required this.subtitle,
    required this.cameraLabel,
    required this.galleryLabel,
  });

  final String title;
  final String subtitle;
  final String cameraLabel;
  final String galleryLabel;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 54,
              height: 6,
              decoration: BoxDecoration(
                color: context.colorTokens.borderUnfocused,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Gap(26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PhotoSourceHeroBadge(),
              const Gap(18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.extraBold24),
                    const Gap(8),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: context.colorTokens.textHint,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(28),
          _PhotoSourceAction(
            icon: Icons.photo_camera_rounded,
            label: cameraLabel,
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          const Gap(10),
          _PhotoSourceAction(
            icon: Icons.photo_library_rounded,
            label: galleryLabel,
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}

class _PhotoSourceHeroBadge extends StatelessWidget {
  const _PhotoSourceHeroBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.primaryVeryLight,
        border: Border.all(color: tokens.primary.withValues(alpha: 0.16)),
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.primary.withValues(alpha: 0.10),
          ),
          child: Icon(
            Icons.add_photo_alternate_rounded,
            color: tokens.primary,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class _PhotoSourceAction extends StatelessWidget {
  const _PhotoSourceAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = context.colorTokens.primary;

    return BounceTap(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.surfaceShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Gap(14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.cardTitle.copyWith(
                  color: context.colorTokens.textBody,
                ),
              ),
            ),
            const Gap(10),
            Icon(Icons.chevron_right_rounded, color: color, size: 26),
          ],
        ),
      ),
    );
  }
}
