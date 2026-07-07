import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";

class CredentialsController extends GetxController {
  CredentialsController({
    required this._appController,
    required this._appNavigator,
    required this.phoneNumber,
  });

  final AppController _appController;
  final AppNavigator _appNavigator;
  final String phoneNumber;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  final RxBool canSubmit = false.obs;
  final RxBool isSubmitting = false.obs;

  void onNameChanged(String value) => _refreshCanSubmit();

  Future<void> onPickBirthDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initial =
        birthDate.value ?? DateTime(now.year - 18, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      birthDate.value = picked;
      _refreshCanSubmit();
    }
  }

  void _refreshCanSubmit() => canSubmit.value =
      nameController.text.trim().isNotEmpty && birthDate.value != null;

  Future<void> onSubmit() async {
    if (!canSubmit.value || isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    await _appController.updateProfile(
      userName: nameController.text.trim(),
      nickName: nicknameController.text.trim(),
      phoneNumber: phoneNumber,
      birthDate: _isoDate(birthDate.value!),
    );
    isSubmitting.value = false;

    await _appNavigator.offAllNamed(AppRoutes.mainNavigation);
  }

  String _isoDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  @override
  void onClose() {
    nameController.dispose();
    nicknameController.dispose();
    super.onClose();
  }
}
