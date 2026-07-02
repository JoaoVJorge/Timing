import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/theme/theme.dart";

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();

    return Obx(
      () => GetMaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppThemes.build(
          seed: appController.accentColor.value,
          brightness: appController.isDarkMode.value ? Brightness.dark : Brightness.light,
        ),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.getPages,
      ),
    );
  }
}
