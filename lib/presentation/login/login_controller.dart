import "dart:async";

import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/sign_in_with_google_use_case.dart";
import "package:help_out/core/services/log/app_logger_service.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class LoginController extends GetxController {
  LoginController({
    required this.signInWithGoogleUseCase,
    required this.appController,
    required this.appNavigator,
    required this.supabaseService,
    required this.logger,
  });

  static const bool isAppleSignInComplete = false;

  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final AppController appController;
  final AppNavigator appNavigator;
  final SupabaseService supabaseService;
  final AppLoggerService logger;

  final RxBool isGoogleSubmitting = false.obs;

  StreamSubscription<AuthState>? _authSubscription;
  bool _isHandlingSignedInUser = false;
  bool _hasCompletedSignIn = false;

  @override
  void onInit() {
    super.onInit();
    final SupabaseClient? client = supabaseService.client;
    if (client == null) {
      return;
    }
    _authSubscription = client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        unawaited(_handleSignedInUser());
      }
    });
  }

  Future<void> onTapGoogleSignIn() async {
    if (isGoogleSubmitting.value) {
      return;
    }

    isGoogleSubmitting.value = true;
    final Either<AppError, void> result = await signInWithGoogleUseCase();
    isGoogleSubmitting.value = false;

    result.fold((error) {
      logger.logAppError("Failed to start Google sign in", error);
      appNavigator.showErrorSnackBar();
    }, (_) => null);
  }

  Future<void> onTapAppleSignIn() async {
    if (!isAppleSignInComplete) {
      final String message = switch (Get.context?.languageCode) {
        "pt" => "Entrar com Apple ainda nao esta completo.",
        "es" => "Iniciar sesion con Apple aun no esta completo.",
        _ => "Sign in with Apple is not complete yet.",
      };
      appNavigator.showErrorSnackBar(message);
      return;
    }
  }

  Future<void> _handleSignedInUser() async {
    if (_isHandlingSignedInUser || _hasCompletedSignIn) {
      return;
    }

    _isHandlingSignedInUser = true;
    try {
      final bool hasRemoteProfile = await appController
          .refreshProfileFromBackend();
      if (!hasRemoteProfile) {
        await _syncProfileFromAuthUser();
      }
      _hasCompletedSignIn = true;
      if (Get.currentRoute != AppRoutes.mainNavigation) {
        await appNavigator.offAllNamed(AppRoutes.mainNavigation);
      }
    } catch (error, stackTrace) {
      logger.logError(
        "Failed to finish Google sign in",
        error: error,
        stackTrace: stackTrace,
      );
      appNavigator.showErrorSnackBar();
    } finally {
      _isHandlingSignedInUser = false;
    }
  }

  Future<void> _syncProfileFromAuthUser() async {
    final User? user = supabaseService.client?.auth.currentUser;
    if (user == null) {
      return;
    }

    final Map<String, dynamic>? metadata = user.userMetadata;
    final String email = user.email ?? "";
    final String userName =
        _metadataText(metadata, "full_name") ??
        _metadataText(metadata, "name") ??
        _nameFromEmail(email);

    await appController.updateProfile(
      userName: userName,
      nickName: "",
      email: email.isEmpty ? null : email,
    );
  }

  String? _metadataText(Map<String, dynamic>? metadata, String key) {
    final Object? value = metadata?[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  String _nameFromEmail(String email) {
    final int atIndex = email.indexOf("@");
    if (atIndex > 0) {
      return email.substring(0, atIndex);
    }
    return "Google User";
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
