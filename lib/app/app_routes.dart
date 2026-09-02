import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:timing/presentation/achievements/achievements_bindings.dart";
import "package:timing/presentation/achievements/achievements_page.dart";
import "package:timing/presentation/category/category_bindings.dart";
import "package:timing/presentation/category/category_page.dart";
import "package:timing/presentation/create_group/create_group_bindings.dart";
import "package:timing/presentation/create_group/create_group_page.dart";
import "package:timing/presentation/create_subject/create_subject_bindings.dart";
import "package:timing/presentation/create_subject/create_subject_page.dart";
import "package:timing/presentation/create_task/create_task_bindings.dart";
import "package:timing/presentation/create_task/create_task_page.dart";
import "package:timing/presentation/daily_goals/daily_goals_bindings.dart";
import "package:timing/presentation/daily_goals/daily_goals_page.dart";
import "package:timing/presentation/edit_group/edit_group_bindings.dart";
import "package:timing/presentation/edit_group/edit_group_page.dart";
import "package:timing/presentation/edit_profile/edit_profile_bindings.dart";
import "package:timing/presentation/edit_profile/edit_profile_page.dart";
import "package:timing/presentation/faq/faq_bindings.dart";
import "package:timing/presentation/faq/faq_page.dart";
import "package:timing/presentation/friends/friends_bindings.dart";
import "package:timing/presentation/friends/friends_page.dart";
import "package:timing/presentation/group_invites/group_invites_bindings.dart";
import "package:timing/presentation/group_invites/group_invites_page.dart";
import "package:timing/presentation/groups/groups_bindings.dart";
import "package:timing/presentation/groups/groups_page.dart";
import "package:timing/presentation/join_group/join_group_bindings.dart";
import "package:timing/presentation/join_group/join_group_page.dart";
import "package:timing/presentation/login/login_bindings.dart";
import "package:timing/presentation/login/login_page.dart";
import "package:timing/presentation/main_navigation/main_navigation_bindings.dart";
import "package:timing/presentation/main_navigation/main_navigation_page.dart";
import "package:timing/presentation/notes/notes_bindings.dart";
import "package:timing/presentation/notes/notes_page.dart";
import "package:timing/presentation/schedule/add_schedule_entry_page.dart";
import "package:timing/presentation/schedule/schedule_bindings.dart";
import "package:timing/presentation/schedule/schedule_page.dart";
import "package:timing/presentation/splash/splash_bindings.dart";
import "package:timing/presentation/splash/splash_page.dart";
import "package:timing/presentation/subject_stats/subject_stats_bindings.dart";
import "package:timing/presentation/subject_stats/subject_stats_page.dart";
import "package:timing/presentation/timer/timer_bindings.dart";
import "package:timing/presentation/timer/timer_page.dart";

class AppRoutes {
  const AppRoutes._();

  static const String splash = "/";
  static const String login = "/login";
  static const String mainNavigation = "/mainNavigation";
  static const String friends = "/friends";
  static const String groupDetails = "/groupDetails";
  static const String category = "/category";
  static const String createSubject = "/createSubject";
  static const String createTask = "/createTask";
  static const String dailyGoals = "/dailyGoals";
  static const String timer = "/timer";
  static const String editProfile = "/editProfile";
  static const String editGroup = "/editGroup";
  static const String faq = "/faq";
  static const String createGroup = "/createGroup";
  static const String groupInvites = "/groupInvites";
  static const String joinGroup = "/joinGroup";
  static const String schedule = "/schedule";
  static const String addScheduleEntry = "/addScheduleEntry";
  static const String notes = "/notes";
  static const String achievements = "/achievements";
  static const String subjectStats = "/subjectStats";

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
      name: mainNavigation,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBindings(),
      transition: Transition.fadeIn,
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
      name: friends,
      page: () => const FriendsPage(),
      binding: FriendsBindings(),
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
      name: groupDetails,
      page: () => const GroupsPage(showGroupFlowOnly: true),
      binding: GroupsBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: groupInvites,
      page: () => const GroupInvitesPage(),
      binding: GroupInvitesBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: editGroup,
      page: () => const EditGroupPage(),
      binding: EditGroupBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: joinGroup,
      page: () => const JoinGroupPage(),
      binding: JoinGroupBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: schedule,
      page: () => const SchedulePage(),
      binding: ScheduleBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: addScheduleEntry,
      page: () => const AddScheduleEntryPage(),
      binding: ScheduleBindings(),
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
    GetPage(
      name: achievements,
      page: () => const AchievementsPage(),
      binding: AchievementsBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
    GetPage(
      name: subjectStats,
      page: () => const SubjectStatsPage(),
      binding: SubjectStatsBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: pageTransitionDuration,
      curve: pageTransitionCurve,
    ),
  ];

  static const Duration pageTransitionDuration = Duration(milliseconds: 260);
  static const Curve pageTransitionCurve = Curves.easeOutCubic;
}
