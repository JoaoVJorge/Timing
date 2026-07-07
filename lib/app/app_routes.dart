import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:help_out/presentation/category/category_bindings.dart";
import "package:help_out/presentation/category/category_page.dart";
import "package:help_out/presentation/config/config_bindings.dart";
import "package:help_out/presentation/config/config_page.dart";
import "package:help_out/presentation/create_group/create_group_bindings.dart";
import "package:help_out/presentation/create_group/create_group_page.dart";
import "package:help_out/presentation/create_subject/create_subject_bindings.dart";
import "package:help_out/presentation/create_subject/create_subject_page.dart";
import "package:help_out/presentation/create_task/create_task_bindings.dart";
import "package:help_out/presentation/create_task/create_task_page.dart";
import "package:help_out/presentation/daily_goals/daily_goals_bindings.dart";
import "package:help_out/presentation/daily_goals/daily_goals_page.dart";
import "package:help_out/presentation/edit_profile/edit_profile_bindings.dart";
import "package:help_out/presentation/edit_profile/edit_profile_page.dart";
import "package:help_out/presentation/faq/faq_bindings.dart";
import "package:help_out/presentation/faq/faq_page.dart";
import "package:help_out/presentation/groups/groups_bindings.dart";
import "package:help_out/presentation/groups/groups_page.dart";
import "package:help_out/presentation/home/home_bindings.dart";
import "package:help_out/presentation/home/home_page.dart";
import "package:help_out/presentation/login/login_bindings.dart";
import "package:help_out/presentation/login/login_page.dart";
import "package:help_out/presentation/main_navigation/main_navigation_bindings.dart";
import "package:help_out/presentation/main_navigation/main_navigation_page.dart";
import "package:help_out/presentation/credentials/credentials_bindings.dart";
import "package:help_out/presentation/credentials/credentials_page.dart";
import "package:help_out/presentation/notes/notes_bindings.dart";
import "package:help_out/presentation/notes/notes_page.dart";
import "package:help_out/presentation/otp/otp_bindings.dart";
import "package:help_out/presentation/otp/otp_page.dart";
import "package:help_out/presentation/phone_login/phone_login_bindings.dart";
import "package:help_out/presentation/phone_login/phone_login_page.dart";
import "package:help_out/presentation/profile/profile_bindings.dart";
import "package:help_out/presentation/profile/profile_page.dart";
import "package:help_out/presentation/schedule/schedule_page.dart";
import "package:help_out/presentation/splash/splash_bindings.dart";
import "package:help_out/presentation/splash/splash_page.dart";
import "package:help_out/presentation/timer/timer_bindings.dart";
import "package:help_out/presentation/timer/timer_page.dart";

class AppRoutes {
  const AppRoutes._();

  static const String splash = "/";
  static const String login = "/login";
  static const String phoneLogin = "/phoneLogin";
  static const String otp = "/otp";
  static const String credentials = "/credentials";
  static const String mainNavigation = "/mainNavigation";
  static const String home = "/home";
  static const String profile = "/profile";
  static const String groups = "/groups";
  static const String config = "/config";
  static const String category = "/category";
  static const String createSubject = "/createSubject";
  static const String createTask = "/createTask";
  static const String dailyGoals = "/dailyGoals";
  static const String timer = "/timer";
  static const String editProfile = "/editProfile";
  static const String faq = "/faq";
  static const String createGroup = "/createGroup";
  static const String schedule = "/schedule";
  static const String notes = "/notes";

  static final List<GetPage<dynamic>> getPages = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      binding: SplashBindings(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: LoginBindings(),
    ),
    GetPage(
      name: phoneLogin,
      page: () => const PhoneLoginPage(),
      binding: PhoneLoginBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: otp,
      page: () => const OtpPage(),
      binding: OtpBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: credentials,
      page: () => const CredentialsPage(),
      binding: CredentialsBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: mainNavigation,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBindings(),
      transition: Transition.fadeIn,
      children: [
        GetPage(
          name: home,
          page: () => const HomePage(),
          binding: HomeBindings(),
        ),
        GetPage(
          name: profile,
          page: () => const ProfilePage(),
          binding: ProfileBindings(),
        ),
        GetPage(
          name: groups,
          page: () => const GroupsPage(),
          binding: GroupsBindings(),
        ),
        GetPage(
          name: config,
          page: () => const ConfigPage(),
          binding: ConfigBindings(),
        ),
      ],
    ),
    GetPage(
      name: category,
      page: () => const CategoryPage(),
      binding: CategoryBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: createSubject,
      page: () => const CreateSubjectPage(),
      binding: CreateSubjectBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: createTask,
      page: () => const CreateTaskPage(),
      binding: CreateTaskBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: dailyGoals,
      page: () => const DailyGoalsPage(),
      binding: DailyGoalsBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: timer,
      page: () => const TimerPage(),
      binding: TimerBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: editProfile,
      page: () => const EditProfilePage(),
      binding: EditProfileBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: faq,
      page: () => const FaqPage(),
      binding: FaqBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: createGroup,
      page: () => const CreateGroupPage(),
      binding: CreateGroupBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: schedule,
      page: () => const SchedulePage(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: notes,
      page: () => const NotesPage(),
      binding: NotesBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
  ];

  static const Duration pageTransitionDuration = Duration(milliseconds: 320);
  static const Curve pageTransitionCurve = Curves.easeInOutCubic;

  static Route? onGenerateChildRoute({
    required RouteSettings settings,
    required String parentRouteName,
  }) {
    if (settings.name == null) {
      return null;
    }

    final GetPage? parentRoute = getPages.firstWhereOrNull(
      (page) => page.name == parentRouteName,
    );
    final GetPage? childRoute = parentRoute?.children.firstWhereOrNull(
      (page) => page.name == settings.name,
    );

    if (childRoute == null) {
      return null;
    }

    Get.routing.args = settings.arguments;
    return GetPageRoute(
      settings: settings,
      page: childRoute.page,
      binding: childRoute.binding,
    );
  }
}
