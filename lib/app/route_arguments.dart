import "package:get/get.dart";
import "package:timing/core/domain/entities/active_timer_session_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";

class RouteArguments {
  const RouteArguments._();

  static T of<T extends Object>(String routeName) {
    final Object? arguments = Get.arguments;
    if (arguments is T) {
      return arguments;
    }
    throw RouteArgumentError(
      routeName: routeName,
      expected: T,
      actual: arguments,
    );
  }

  static T? maybeOf<T extends Object>() {
    final Object? arguments = Get.arguments;
    return arguments is T ? arguments : null;
  }
}

class CreateSubjectRouteArguments {
  const CreateSubjectRouteArguments({required this.category, this.initialName});

  final TimeCategoryType category;
  final String? initialName;
}

class CreateTaskRouteArguments {
  const CreateTaskRouteArguments({this.initialName});

  final String? initialName;
}

class TimerRouteArguments {
  const TimerRouteArguments({required this.subject, this.restoredSession});

  final SubjectEntity subject;
  final ActiveTimerSessionEntity? restoredSession;
}
