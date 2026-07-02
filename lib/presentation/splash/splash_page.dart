import "package:flutter/material.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: context.colorTokens.primary,
    body: Center(
      child: Text(
        AppConstants.appTitle,
        style: context.textStyles.textPrimaryButton.copyWith(fontSize: 32, fontWeight: FontWeight.w900),
      ),
    ),
  );
}
