import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/request_phone_code_use_case.dart";
import "package:help_out/core/services/log/app_logger_service.dart";

class PhoneLoginController extends GetxController {
  PhoneLoginController({
    required this._requestPhoneCodeUseCase,
    required this._appNavigator,
    required this._logger,
  });

  final RequestPhoneCodeUseCase _requestPhoneCodeUseCase;
  final AppNavigator _appNavigator;
  final AppLoggerService _logger;

  final TextEditingController emailController = TextEditingController();
  final RxBool canSubmit = false.obs;
  final RxBool isSubmitting = false.obs;

  void onEmailChanged(String value) =>
      canSubmit.value = _isValidEmail(value.trim());

  Future<void> onTapSendCode() async {
    final String emailAddress = emailController.text.trim().toLowerCase();
    if (!_isValidEmail(emailAddress) || isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    final Either<AppError, void> result = await _requestPhoneCodeUseCase(
      emailAddress,
    );
    isSubmitting.value = false;

    result.fold(
      (error) {
        _logger.logAppError(
          "Failed to request email OTP for ${_maskedEmail(emailAddress)}",
          error,
        );
        _appNavigator.showErrorSnackBar();
      },
      (_) {
        _appNavigator.toNamed(AppRoutes.otp, arguments: emailAddress);
      },
    );
  }

  bool _isValidEmail(String value) =>
      RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value);

  String _maskedEmail(String value) {
    final int atIndex = value.indexOf("@");
    if (atIndex <= 1) {
      return "***";
    }
    return "${value[0]}***${value.substring(atIndex)}";
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
