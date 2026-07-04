import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class EditProfileController extends GetxController {
  EditProfileController({required this._appController, required this._appNavigator});

  final AppController _appController;
  final AppNavigator _appNavigator;

  late final TextEditingController nameController = TextEditingController(text: _appController.userName.value);
  late final TextEditingController nickNameController = TextEditingController(text: _appController.nickName.value);
  late final TextEditingController emailController = TextEditingController(text: _appController.email.value ?? "");
  late final TextEditingController phoneController = TextEditingController(text: _appController.phoneNumber.value ?? "");

  Rx<Color> get accentColor => _appController.accentColor;
  RxInt get avatarIconIndex => _appController.avatarIconIndex;
  final RxBool isSaving = false.obs;

  void onSelectAccentColor(Color color) => _appController.setAccentColor(color);

  void onSelectAvatarIcon(int index) => _appController.setAvatarIconIndex(index);

  Future<void> onTapSave() async {
    isSaving.value = true;

    final Either<AppError, void> result = await _appController.updateProfile(
      userName: nameController.text.trim(),
      nickName: nickNameController.text.trim(),
      email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
      phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
    );

    isSaving.value = false;
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (_) => _appNavigator.showSuccessSnackBar(Get.context!.l10n.profileSavedMessage),
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
