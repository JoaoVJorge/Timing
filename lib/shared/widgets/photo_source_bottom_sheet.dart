import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:image_picker/image_picker.dart";

Future<ImageSource?> showPhotoSourceBottomSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String cameraLabel,
  required String galleryLabel,
  required String cancelLabel,
}) => showModalBottomSheet<ImageSource>(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colorTokens.transparent,
  barrierColor: context.colorTokens.black.withValues(alpha: 0.54),
  builder: (context) => _PhotoSourceBottomSheet(
    title: title,
    subtitle: subtitle,
    cameraLabel: cameraLabel,
    galleryLabel: galleryLabel,
    cancelLabel: cancelLabel,
  ),
);

class _PhotoSourceBottomSheet extends StatelessWidget {
  const _PhotoSourceBottomSheet({
    required this.title,
    required this.subtitle,
    required this.cameraLabel,
    required this.galleryLabel,
    required this.cancelLabel,
  });

  final String title;
  final String subtitle;
  final String cameraLabel;
  final String galleryLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 126,
            height: 7,
            decoration: BoxDecoration(
              color: context.colorTokens.textHint.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Gap(30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.extraBold24.copyWith(
              color: context.colorTokens.dialogText,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const Gap(6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyLarge.copyWith(
              color: context.colorTokens.dialogTextMuted,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.22,
            ),
          ),
          const Gap(28),
          _PhotoSourceAction(
            icon: Icons.photo_camera_rounded,
            label: cameraLabel,
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          const Gap(14),
          _PhotoSourceAction(
            icon: Icons.photo_library_rounded,
            label: galleryLabel,
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          const Gap(22),
          Divider(height: 1, color: context.colorTokens.divider),
          const Gap(12),
          BounceTap(
            onTap: () => Navigator.of(context).pop(),
            pressedScale: 0.98,
            child: SizedBox(
              height: 48,
              child: Center(
                child: Text(
                  cancelLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge.copyWith(
                    color: context.colorTokens.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
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
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.98,
    child: Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: context.colorTokens.primary, size: 31),
          ),
          const Gap(24),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.dialogText,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Gap(12),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colorTokens.primary,
            size: 34,
          ),
        ],
      ),
    ),
  );
}
