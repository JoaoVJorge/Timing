import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/request_phone_code_use_case.dart";
import "package:help_out/core/domain/use_cases/verify_phone_code_use_case.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class OtpController extends GetxController {
  OtpController({
    required this._verifyPhoneCodeUseCase,
    required this._requestPhoneCodeUseCase,
    required this._appController,
    required this._appNavigator,
    required this.phoneNumber,
  });

  static const int codeLength = 6;
  static const int codeValiditySeconds = 120;

  final VerifyPhoneCodeUseCase _verifyPhoneCodeUseCase;
  final RequestPhoneCodeUseCase _requestPhoneCodeUseCase;
  final AppController _appController;
  final AppNavigator _appNavigator;
  final String phoneNumber;

  final TextEditingController codeController = TextEditingController();
  final RxBool canSubmit = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt secondsRemaining = codeValiditySeconds.obs;

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    _restartCountdown();
  }

  void _restartCountdown() {
    _countdownTimer?.cancel();
    secondsRemaining.value = codeValiditySeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining.value <= 1) {
        secondsRemaining.value = 0;
        _countdownTimer?.cancel();
        return;
      }
      secondsRemaining.value--;
    });
  }

  void onCodeChanged(String value) {
    canSubmit.value = value.length == codeLength;
    if (value.length == codeLength) {
      onTapVerify();
    }
  }

  Future<void> onTapVerify() async {
    final String code = codeController.text;
    if (code.length != codeLength || isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    final Either<AppError, bool> result = await _verifyPhoneCodeUseCase(
      phoneNumber: phoneNumber,
      code: code,
    );
    isSubmitting.value = false;

    result.fold((error) => _appNavigator.showErrorSnackBar(), (isValid) {
      if (!isValid) {
        _appNavigator.showErrorSnackBar(Get.context!.l10n.invalidCodeError);
        return;
      }
      _onVerified();
    });
  }

  void _onVerified() {
    final bool hasAccount = _appController.userName.value.isNotEmpty;
    if (hasAccount) {
      _appNavigator.offAllNamed(AppRoutes.mainNavigation);
    } else {
      _appNavigator.toNamed(AppRoutes.credentials, arguments: phoneNumber);
    }
  }

  Future<void> onTapResend() async {
    final Either<AppError, void> result = await _requestPhoneCodeUseCase(
      phoneNumber,
    );
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
      _restartCountdown();
      _appNavigator.showSuccessSnackBar(Get.context!.l10n.codeResentMessage);
    });
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    codeController.dispose();
    super.onClose();
  }
}
