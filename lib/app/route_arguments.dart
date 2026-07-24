import "package:get/get.dart";
import "package:help_out/core/domain/errors/app_error.dart";

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
