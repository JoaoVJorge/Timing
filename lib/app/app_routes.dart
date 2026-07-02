import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:help_out/presentation/category/category_bindings.dart";
import "package:help_out/presentation/category/category_page.dart";
import "package:help_out/presentation/config/config_bindings.dart";
import "package:help_out/presentation/config/config_page.dart";
import "package:help_out/presentation/home/home_bindings.dart";
import "package:help_out/presentation/home/home_page.dart";
import "package:help_out/presentation/login/login_bindings.dart";
import "package:help_out/presentation/login/login_page.dart";
import "package:help_out/presentation/main_navigation/main_navigation_bindings.dart";
import "package:help_out/presentation/main_navigation/main_navigation_page.dart";
import "package:help_out/presentation/splash/splash_bindings.dart";
import "package:help_out/presentation/splash/splash_page.dart";
import "package:help_out/presentation/timer/timer_bindings.dart";
import "package:help_out/presentation/timer/timer_page.dart";

class AppRoutes {
  const AppRoutes._();

  static const String splash = "/";
  static const String login = "/login";
  static const String mainNavigation = "/mainNavigation";
  static const String home = "/home";
  static const String config = "/config";
  static const String category = "/category";
  static const String timer = "/timer";

  static final List<GetPage<dynamic>> getPages = [
    GetPage(name: splash, page: () => const SplashPage(), binding: SplashBindings()),
    GetPage(name: login, page: () => const LoginPage(), binding: LoginBindings()),
    GetPage(
      name: mainNavigation,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBindings(),
      transition: Transition.fadeIn,
      children: [
        GetPage(name: home, page: () => const HomePage(), binding: HomeBindings()),
        GetPage(name: config, page: () => const ConfigPage(), binding: ConfigBindings()),
      ],
    ),
    GetPage(name: category, page: () => const CategoryPage(), binding: CategoryBindings()),
    GetPage(name: timer, page: () => const TimerPage(), binding: TimerBindings()),
  ];

  static Route? onGenerateChildRoute({required RouteSettings settings, required String parentRouteName}) {
    if (settings.name == null) {
      return null;
    }

    final GetPage? parentRoute = getPages.firstWhereOrNull((page) => page.name == parentRouteName);
    final GetPage? childRoute = parentRoute?.children.firstWhereOrNull((page) => page.name == settings.name);

    if (childRoute == null) {
      return null;
    }

    Get.routing.args = settings.arguments;
    return GetPageRoute(settings: settings, page: childRoute.page, binding: childRoute.binding);
  }
}
