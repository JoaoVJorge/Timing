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
  required String cancelLabel,
  bool isCompact = false,
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
    isCompact: isCompact,
  ),
);

class _PhotoSourceBottomSheet extends StatelessWidget {
  const _PhotoSourceBottomSheet({
    required this.title,
    required this.subtitle,
    required this.cameraLabel,
    required this.galleryLabel,
    required this.cancelLabel,
    required this.isCompact,
  });

  final String title;
  final String subtitle;
  final String cameraLabel;
  final String galleryLabel;
  final String cancelLabel;
  final bool isCompact;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 12, 20, isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 72 : 126,
            height: isCompact ? 5 : 7,
            decoration: BoxDecoration(
              color: context.colorTokens.textHint.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Gap(isCompact ? 16 : 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.extraBold24.copyWith(
              color: context.colorTokens.dialogText,
              fontSize: isCompact ? 21 : 25,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          Gap(isCompact ? 4 : 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: isCompact ? 2 : null,
            overflow: isCompact ? TextOverflow.ellipsis : null,
            style: context.textStyles.bodyLarge.copyWith(
              color: context.colorTokens.dialogTextMuted,
              fontSize: isCompact ? 14 : 17,
              fontWeight: FontWeight.w600,
              height: 1.22,
            ),
          ),
          Gap(isCompact ? 16 : 28),
          _PhotoSourceAction(
            icon: Icons.photo_camera_rounded,
            label: cameraLabel,
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
            isCompact: isCompact,
          ),
          Gap(isCompact ? 8 : 14),
          _PhotoSourceAction(
            icon: Icons.photo_library_rounded,
            label: galleryLabel,
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            isCompact: isCompact,
          ),
          Gap(isCompact ? 12 : 22),
          Divider(height: 1, color: context.colorTokens.divider),
          Gap(isCompact ? 6 : 12),
          BounceTap(
            onTap: () => Navigator.of(context).pop(),
            pressedScale: 0.98,
            child: SizedBox(
              height: isCompact ? 38 : 48,
              child: Center(
                child: Text(
                  cancelLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge.copyWith(
                    color: context.colorTokens.primary,
                    fontSize: isCompact ? 15 : 17,
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
    required this.isCompact,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.98,
    child: Container(
      constraints: BoxConstraints(minHeight: isCompact ? 64 : 88),
      padding: EdgeInsets.fromLTRB(
        14,
        isCompact ? 9 : 14,
        12,
        isCompact ? 9 : 14,
      ),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          Container(
            width: isCompact ? 44 : 66,
            height: isCompact ? 44 : 66,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
            ),
            child: Icon(
              icon,
              color: context.colorTokens.primary,
              size: isCompact ? 23 : 31,
            ),
          ),
          Gap(isCompact ? 14 : 24),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.dialogText,
                fontSize: isCompact ? 16 : 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Gap(isCompact ? 8 : 12),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colorTokens.primary,
            size: isCompact ? 26 : 34,
          ),
        ],
      ),
    ),
  );
}
