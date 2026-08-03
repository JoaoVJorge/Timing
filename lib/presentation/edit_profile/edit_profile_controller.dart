import "dart:convert";
import "dart:typed_data";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:image_picker/image_picker.dart";

class EditProfileController extends GetxController {
  EditProfileController({
    required this._appController,
    required this._appNavigator,
  });

  final AppController _appController;
  final AppNavigator _appNavigator;

  late final TextEditingController nameController = TextEditingController(
    text: _appController.userName.value,
  );
  late final TextEditingController nickNameController = TextEditingController(
    text: _appController.nickName.value,
  );
  late final TextEditingController emailController = TextEditingController(
    text: _appController.email.value ?? "",
  );
  late final TextEditingController phoneController = TextEditingController(
    text: _appController.phoneNumber.value ?? "",
  );

  Rx<Color> get accentColor => _appController.accentColor;
  RxInt get avatarIconIndex => _appController.avatarIconIndex;
  Rx<String?> get profilePhotoBase64 => _appController.profilePhotoBase64;

  Uint8List? get profilePhotoBytes => _appController.profilePhotoBytes;
  final RxBool isSaving = false.obs;
  final ImagePicker _imagePicker = ImagePicker();

  void onSelectAccentColor(Color color) => _appController.setAccentColor(color);

  void onSelectAvatarIcon(int index) =>
      _appController.setAvatarIconIndex(index);

  Future<void> onTapProfilePhoto() async {
    if (profilePhotoBase64.value == null) {
      await onTapSelectPhoto();
      return;
    }

    final BuildContext context = Get.context!;
    final bool? shouldRemove = await _appNavigator.dialog<bool>(
      child: _RemoveProfilePhotoDialog(
        title: _removePhotoTitle(context),
        content: _removePhotoContent(context),
        cancelLabel: context.l10n.cancelButton,
        removeLabel: context.l10n.profilePhotoRemoveLabel,
      ),
    );

    if (shouldRemove == true) {
      await onTapRemovePhoto();
    }
  }

  Future<void> onTapSelectPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 82,
    );
    if (image == null) {
      return;
    }

    final List<int> bytes = await image.readAsBytes();
    await _appController.setProfilePhotoBase64(base64Encode(bytes));
  }

  Future<void> onTapRemovePhoto() => _appController.setProfilePhotoBase64(null);

  String _removePhotoTitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Quitar foto?",
        "pt" => "Remover foto?",
        _ => "Remove photo?",
      };

  String _removePhotoContent(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Tu avatar volverá a aparecer en el perfil.",
        "pt" => "Seu avatar voltará a aparecer no perfil.",
        _ => "Your avatar will show on the profile again.",
      };

  Future<void> onTapSave() async {
    isSaving.value = true;

    final Either<AppError, void> result = await _appController.updateProfile(
      userName: nameController.text.trim(),
      nickName: nickNameController.text.trim(),
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      phoneNumber: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      birthDate: _appController.birthDate.value,
      profilePhotoBase64: profilePhotoBase64.value,
    );

    isSaving.value = false;
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (_) => _appNavigator.showSuccessSnackBar(
        Get.context!.l10n.profileSavedMessage,
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    nickNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}

class _RemoveProfilePhotoDialog extends StatelessWidget {
  const _RemoveProfilePhotoDialog({
    required this.title,
    required this.content,
    required this.cancelLabel,
    required this.removeLabel,
  });

  final String title;
  final String content;
  final String cancelLabel;
  final String removeLabel;

  @override
  Widget build(BuildContext context) => Dialog(
    elevation: 0,
    backgroundColor: context.colorTokens.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorTokens.primaryVeryLight,
              border: Border.all(color: context.colorTokens.primaryVeryLight),
            ),
            child: Icon(
              Icons.photo_camera_rounded,
              color: context.colorTokens.primary,
              size: 36,
            ),
          ),
          const Gap(24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorTokens.dialogText,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const Gap(18),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorTokens.dialogTextMuted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const Gap(24),
          Divider(color: context.colorTokens.divider),
          const Gap(22),
          Row(
            children: [
              Expanded(
                child: _RemoveProfilePhotoButton(
                  label: cancelLabel,
                  textColor: context.colorTokens.dialogTextMuted,
                  borderColor: context.colorTokens.borderFocused,
                  onTap: () => appNavigator.back<bool>(result: false),
                ),
              ),
              const Gap(14),
              Expanded(
                child: _RemoveProfilePhotoButton(
                  label: removeLabel,
                  textColor: context.colorTokens.white,
                  backgroundColor: context.colorTokens.primary,
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

class _RemoveProfilePhotoButton extends StatelessWidget {
  const _RemoveProfilePhotoButton({
    required this.label,
    required this.textColor,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  final String label;
  final Color textColor;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorTokens.transparent,
        borderRadius: BorderRadius.circular(14),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
