import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:get/get.dart";
import "package:timing/app/app_constants.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/theme/theme.dart";

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
          brightness: appController.isDarkMode.value
              ? Brightness.dark
              : Brightness.light,
        ),
        locale: appController.selectedLocale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          FlutterQuillLocalizations.delegate,
        ],
        builder: (context, child) => Directionality(
          textDirection: TextDirection.ltr,
          child: Obx(() {
            final bool isOnline =
                Get.find<ConnectivityService>().isOnline.value;
            return Column(
              children: [
                if (!isOnline)
                  Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: SafeArea(
                      bottom: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            AppLocalizations.of(context).groupsOfflineTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: !isOnline,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          }),
        ),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.getPages,
      ),
    );
  }
}
