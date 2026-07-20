import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/request_phone_code_use_case.dart";
import "package:help_out/presentation/phone_login/country_codes.dart";

class PhoneLoginController extends GetxController {
  PhoneLoginController({
    required this._requestPhoneCodeUseCase,
    required this._appNavigator,
  });

  final RequestPhoneCodeUseCase _requestPhoneCodeUseCase;
  final AppNavigator _appNavigator;

  final TextEditingController phoneController = TextEditingController();
  final Rx<CountryCode> selectedCountry = CountryCodes.brazil.obs;
  final RxBool canSubmit = false.obs;
  final RxBool isSubmitting = false.obs;

  void onPhoneChanged(String value) =>
      canSubmit.value = _digitsOf(value).length >= 8;

  void onSelectCountry(CountryCode country) => selectedCountry.value = country;

  Future<void> onTapSendCode() async {
    if (_digitsOf(phoneController.text).length < 8 || isSubmitting.value) {
      return;
    }

    final String phoneNumber =
        "${selectedCountry.value.dialCode} ${phoneController.text.trim()}";

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
