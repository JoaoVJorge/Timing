import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/request_phone_code_use_case.dart";

class PhoneLoginController extends GetxController {
  PhoneLoginController({
    required this._requestPhoneCodeUseCase,
    required this._appNavigator,
  });

  final RequestPhoneCodeUseCase _requestPhoneCodeUseCase;
  final AppNavigator _appNavigator;

  final TextEditingController phoneController = TextEditingController();
  final RxBool canSubmit = false.obs;
  final RxBool isSubmitting = false.obs;

  void onPhoneChanged(String value) =>
      canSubmit.value = _digitsOf(value).length >= 8;

  Future<void> onTapSendCode() async {
    final String phoneNumber = phoneController.text.trim();
    if (_digitsOf(phoneNumber).length < 8) {
      return;
    }

    isSubmitting.value = true;
    final Either<AppError, void> result = await _requestPhoneCodeUseCase(
      phoneNumber,
    );
    isSubmitting.value = false;

    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
      _appNavigator.toNamed(AppRoutes.otp, arguments: phoneNumber);
    });
  }

  String _digitsOf(String value) => value.replaceAll(RegExp(r"[^0-9]"), "");

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
