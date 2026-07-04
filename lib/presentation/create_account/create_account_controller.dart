import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";

class CreateAccountController extends GetxController {
  CreateAccountController({required this._appController, required this._appNavigator});

  final AppController _appController;
  final AppNavigator _appNavigator;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxBool canSubmit = false.obs;
  final RxBool isSubmitting = false.obs;

  void onNameChanged(String value) => canSubmit.value = value.trim().isNotEmpty;

  Future<void> onSubmit() async {
    final String name = nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    isSubmitting.value = true;
    await _appController.updateProfile(
      userName: name,
      nickName: nicknameController.text.trim(),
      phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
    );
    isSubmitting.value = false;

    await _appNavigator.offAllNamed(AppRoutes.mainNavigation);
  }

  @override
  void onClose() {
    nameController.dispose();
    nicknameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
