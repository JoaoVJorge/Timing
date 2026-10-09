/// A failure the app knows how to explain to the user. The subtype decides
/// which explanation applies; [operation], [cause] and [stackTrace] are
/// diagnostics for the log and never reach the screen.
///
/// Turning a failure into text for the user happens in one place only: the
/// `localized` extension, which every screen reaches through
/// `AppNavigator.showError`.
sealed class AppError {
  const AppError({this.operation, this.cause, this.stackTrace});

  /// What was being attempted, e.g. `rpc public.create_group_with_members`.
  final String? operation;

  /// The exception, or a description, behind this failure.
  final Object? cause;

  final StackTrace? stackTrace;

  /// Diagnostic text for the log.
  String get debugDescription {
    final String? attempted = operation;
    final Object? reason = cause;
    return [
      runtimeType.toString(),
      if (attempted != null) "($attempted)",
      if (reason != null) ": $reason",
    ].join();
  }

  @override
  String toString() => debugDescription;
}

/// The backend could not be reached: no network, a timeout or a gateway
/// failure. Trying again later can work.
final class OfflineError extends AppError {
  const OfflineError({super.operation, super.cause, super.stackTrace});
}

/// The action needs a signed-in user and there is none.
final class SignedOutError extends AppError {
  const SignedOutError({super.operation, super.cause, super.stackTrace});
}

/// The backend answered and refused the action for good, so repeating the same
/// request cannot succeed.
final class RejectedError extends AppError {
  const RejectedError({
    this.code,
    super.operation,
    super.cause,
    super.stackTrace,
  });

  /// The backend's own error code (a SQLSTATE or PostgREST code), when it sent
  /// one.
  final String? code;
}

/// Data saved on this device could not be read back or written.
final class LocalDataError extends AppError {
  const LocalDataError({super.operation, super.cause, super.stackTrace});
}

/// A failure the app has no more specific explanation for.
final class UnexpectedError extends AppError {
  const UnexpectedError({super.operation, super.cause, super.stackTrace});
}

/// A screen was opened without the arguments it needs.
final class RouteArgumentError extends AppError {
  RouteArgumentError({
    required this.routeName,
    required this.expected,
    required this.actual,
  }) : super(
         operation: "route $routeName",
         cause:
             "expected arguments of type $expected but received "
             "${actual == null ? "null" : actual.runtimeType}",
       );

  final String routeName;
  final Type expected;
  final Object? actual;
}
