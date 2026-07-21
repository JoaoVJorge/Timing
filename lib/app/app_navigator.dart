import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

final AppNavigator appNavigator = Get.find();

class AppNavigator {
  Map<String, String?> get parameters => Get.parameters;

  dynamic get arguments => Get.arguments;

  double get screenHeight => Get.height;

  double get screenWidth => Get.width;

  void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) => Get.back<T>(
    result: result,
    closeOverlays: closeOverlays,
    canPop: canPop,
    id: id,
  );

  Future<T?>? toNamed<T>(
    String page, {
    Object? arguments,
    int? id,
    bool preventDuplicates = true,
  }) {
    final Future<dynamic>? result = Get.toNamed<dynamic>(
      page,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
    );
    return result?.then((value) => value as T?);
  }

  Future<T?>? offNamed<T>(
    String page, {
    Object? arguments,
    int? id,
    bool preventDuplicates = true,
  }) {
    final Future<dynamic>? result = Get.offNamed<dynamic>(
      page,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
    );
    return result?.then((value) => value as T?);
  }

  Future<T?>? offAllNamed<T>(
    String newRouteName, {
    Object? arguments,
    int? id,
  }) {
    final Future<dynamic>? result = Get.offAllNamed<dynamic>(
      newRouteName,
      arguments: arguments,
      id: id,
    );
    return result?.then((value) => value as T?);
  }

  Future<T?> dialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    bool useSafeArea = true,
  }) => Get.dialog<T>(
    child,
    barrierDismissible: barrierDismissible,
    useSafeArea: useSafeArea,
  );

  Future<T?> modalBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool useSafeArea = true,
  }) => showModalBottomSheet<T>(
    context: Get.context!,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    builder: (context) => child,
  );

  void showSnackBar({
    required String text,
    bool isAnError = false,
    Color? backgroundColor,
  }) {
    final BuildContext context = Get.context!;
    Get
      ..closeCurrentSnackbar()
      ..rawSnackbar(
        messageText: Text(text, style: context.textStyles.textPrimaryButton),
        margin: const EdgeInsets.only(top: 12, right: 20, left: 20),
        padding: const EdgeInsets.all(16),
        borderRadius: 8,
        snackPosition: SnackPosition.TOP,
        backgroundColor:
            backgroundColor ??
            (isAnError
                ? context.colorTokens.error
                : context.colorTokens.primary),
      );
  }

  void showErrorSnackBar([String? text]) => showSnackBar(
    text: text ?? Get.context!.l10n.genericErrorMessage,
    isAnError: true,
  );

  void showSuccessSnackBar(String text) => showSnackBar(
    text: text,
    backgroundColor: Get.context!.colorTokens.success,
  );
}
