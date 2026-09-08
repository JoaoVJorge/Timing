import "dart:typed_data";

import "package:crop_your_image/crop_your_image.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:image/image.dart" as image_lib hide ImageFormat;
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

Future<Uint8List?> showProfilePhotoCropDialog({
  required BuildContext context,
  required Uint8List image,
}) => showDialog<Uint8List>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _ProfilePhotoCropDialog(image: image),
);

class _ProfilePhotoCropDialog extends StatefulWidget {
  const _ProfilePhotoCropDialog({required this.image});

  final Uint8List image;

  @override
  State<_ProfilePhotoCropDialog> createState() =>
      _ProfilePhotoCropDialogState();
}

class _ProfilePhotoCropDialogState extends State<_ProfilePhotoCropDialog> {
  final CropController _cropController = CropController();
  bool _isCropping = false;
  bool _didFail = false;

  void _onCropped(CropResult result) {
    switch (result) {
      case CropSuccess(:final croppedImage):
        if (mounted) {
          Navigator.of(context).pop(croppedImage);
        }
      case CropFailure():
        if (mounted) {
          setState(() {
            _isCropping = false;
            _didFail = true;
          });
        }
    }
  }

  void _crop() {
    if (_isCropping) {
      return;
    }
    setState(() {
      _isCropping = true;
      _didFail = false;
    });
    _cropController.crop();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    elevation: 0,
    backgroundColor: context.colorTokens.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.cropProfilePhotoTitle,
            textAlign: TextAlign.center,
            style: context.textStyles.extraBold24.copyWith(
              color: context.colorTokens.dialogText,
              fontSize: 22,
            ),
          ),
          const Gap(8),
          Text(
            context.l10n.cropProfilePhotoHint,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.dialogTextMuted,
            ),
          ),
          const Gap(16),
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Crop(
                  image: widget.image,
                  controller: _cropController,
                  onCropped: _onCropped,
                  imageCropper: const _ProfilePhotoImageCropper(),
                  withCircleUi: true,
                  interactive: true,
                  fixCropRect: true,
                  initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                    size: 0.82,
                    aspectRatio: 1,
                  ),
                  baseColor: context.colorTokens.black,
                  maskColor: context.colorTokens.black.withValues(alpha: 0.58),
                  cornerDotBuilder: (size, edgeAlignment) =>
                      DotControl(color: context.colorTokens.primary),
                  progressIndicator: Center(
                    child: CircularProgressIndicator(
                      color: context.colorTokens.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_didFail) ...[
            const Gap(12),
            Text(
              context.l10n.cropProfilePhotoFailure,
              textAlign: TextAlign.center,
              style: context.textStyles.caption.copyWith(
                color: context.colorTokens.error,
              ),
            ),
          ],
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _CropDialogButton(
                  label: context.l10n.cancelButton,
                  foreground: context.colorTokens.primary,
                  borderColor: context.colorTokens.primary,
                  onTap: _isCropping ? null : () => Navigator.of(context).pop(),
                ),
              ),
              const Gap(12),
              Expanded(
                child: _CropDialogButton(
                  label: context.l10n.cropProfilePhotoConfirm,
                  foreground: context.colorTokens.primaryForeground,
                  gradient: context.colorTokens.primaryGradient,
                  onTap: _isCropping ? null : _crop,
                  isLoading: _isCropping,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ProfilePhotoImageCropper extends ImageCropper<image_lib.Image> {
  const _ProfilePhotoImageCropper();

  @override
  RectValidator<image_lib.Image> get rectValidator => defaultRectValidator;

  @override
  RectCropper<image_lib.Image> get rectCropper => _cropProfilePhoto;

  @override
  CircleCropper<image_lib.Image> get circleCropper => _cropCircularProfilePhoto;
}

Uint8List _cropProfilePhoto(
  image_lib.Image original, {
  required Offset topLeft,
  required Size size,
  required ImageFormat? outputFormat,
}) => image_lib.encodeJpg(
  image_lib.copyCrop(
    original,
    x: topLeft.dx.toInt(),
    y: topLeft.dy.toInt(),
    width: size.width.toInt(),
    height: size.height.toInt(),
  ),
  quality: 82,
);

Uint8List _cropCircularProfilePhoto(
  image_lib.Image original, {
  required Offset center,
  required double radius,
  required ImageFormat? outputFormat,
}) => image_lib.encodePng(
  image_lib.copyCropCircle(
    original,
    centerX: center.dx.toInt(),
    centerY: center.dy.toInt(),
    radius: radius.toInt(),
  ),
);

class _CropDialogButton extends StatelessWidget {
  const _CropDialogButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.borderColor,
    this.gradient,
    this.isLoading = false,
  });

  final String label;
  final Color foreground;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Gradient? gradient;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: onTap == null,
    child: BounceTap(
      onTap: onTap ?? () {},
      pressedScale: 0.97,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: onTap == null ? 0.62 : 1,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: foreground,
                  ),
                )
              : Text(
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
      ),
    ),
  );
}
