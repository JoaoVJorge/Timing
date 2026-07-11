import "package:flutter/material.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<Color?>(
    tween: ColorTween(
      begin: context.colorTokens.surfaceInnerLayer,
      end: context.colorTokens.primary,
    ),
    duration: AppConstants.splashScreenDuration,
    curve: Curves.easeInOut,
    builder: (context, color, child) => AppScaffold(
      backgroundColor: color,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 1.6,
              child: Image.asset(
                "assets/images/logo_without_background.png",
                height: 75,
              ),
            ),
            Text(
              AppConstants.appTitle,
              style: context.textStyles.textPrimaryButton.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
