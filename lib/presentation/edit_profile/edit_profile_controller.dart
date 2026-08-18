import "dart:convert";
import "dart:typed_data";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/enums/auth_identity_provider.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_linked_auth_providers_use_case.dart";
import "package:timing/core/domain/use_cases/link_auth_provider_use_case.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/photo_source_bottom_sheet.dart";
import "package:image_picker/image_picker.dart";

class EditProfileController extends GetxController {
  EditProfileController({
    required this._appController,
    required this._appNavigator,
    required this._getLinkedAuthProvidersUseCase,
    required this._linkAuthProviderUseCase,
  });

  final AppController _appController;
  final AppNavigator _appNavigator;
  final GetLinkedAuthProvidersUseCase _getLinkedAuthProvidersUseCase;
  final LinkAuthProviderUseCase _linkAuthProviderUseCase;

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
  final RxBool isGoogleLinked = false.obs;
  final RxBool isAppleLinked = false.obs;
  final RxBool isLinkingGoogle = false.obs;
  final RxBool isLinkingApple = false.obs;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    refreshLinkedAuthProviders();
  }

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
        title: context.l10n.removePhotoDialogTitle,
        content: context.l10n.removePhotoDialogContent,
        cancelLabel: context.l10n.cancelButton,
        removeLabel: context.l10n.profilePhotoRemoveLabel,
      ),
    );

    if (shouldRemove == true) {
      await onTapRemovePhoto();
    }
  }

  Future<void> onTapSelectPhoto() async {
    final ImageSource? source = await _pickImageSource();
    if (source == null) {
      return;
    }
    final XFile? image = await _imagePicker.pickImage(
      source: source,
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

  Future<ImageSource?> _pickImageSource() {
    final BuildContext? context = Get.context;
    if (context == null) {
      return Future<ImageSource?>.value(null);
    }
    return showPhotoSourceBottomSheet(
      context: context,
      title: context.l10n.profilePhotoSourceTitle,
      subtitle: context.l10n.profilePhotoSourceSubtitle,
      cameraLabel: context.l10n.photoCameraLabel,
      galleryLabel: context.l10n.photoGalleryLabel,
    );
  }

  Future<void> refreshLinkedAuthProviders() async {
    final result = await _getLinkedAuthProvidersUseCase();
    result.fold((error) => null, (providers) {
      isGoogleLinked.value = providers.contains(
        AuthIdentityProvider.google.providerKey,
      );
      isAppleLinked.value = providers.contains(
        AuthIdentityProvider.apple.providerKey,
      );
    });
  }

  Future<void> onTapLinkGoogle() => _linkProvider(AuthIdentityProvider.google);

  Future<void> onTapLinkApple() => _linkProvider(AuthIdentityProvider.apple);

  Future<void> _linkProvider(AuthIdentityProvider provider) async {
    final bool alreadyLinked = switch (provider) {
      AuthIdentityProvider.google => isGoogleLinked.value,
      AuthIdentityProvider.apple => isAppleLinked.value,
    };
    if (alreadyLinked) {
      _appNavigator.showSuccessSnackBar(
        Get.context!.l10n.authProviderConnected,
      );
      return;
    }

    final RxBool loading = switch (provider) {
      AuthIdentityProvider.google => isLinkingGoogle,
      AuthIdentityProvider.apple => isLinkingApple,
    };
    if (loading.value) {
      return;
    }

    loading.value = true;
    final result = await _linkAuthProviderUseCase(provider);
    loading.value = false;
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(
        Get.context!.l10n.linkAuthProviderFailure,
      ),
      (launched) {
        if (!launched) {
          _appNavigator.showErrorSnackBar(
            Get.context!.l10n.linkAuthProviderFailure,
          );
          return;
        }
        _appNavigator.showSuccessSnackBar(
          Get.context!.l10n.linkAuthProviderStarted,
        );
      },
    );
  }

  Future<void> onTapSave() async {
    isSaving.value = true;

    final Either<AppError, void> result = await _appController.updateProfile(
      userName: nameController.text.trim(),
      nickName: nickNameController.text.trim(),
      email: _appController.email.value,
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
