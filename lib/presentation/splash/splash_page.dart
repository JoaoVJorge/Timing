import "package:flutter/material.dart";
import "package:timing/app/app_constants.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/app_scaffold.dart";

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
            Center(
              child: Transform.scale(
                scale: 1.3,
                child: Image.asset(AppConstants.appLogo, height: 110),
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
