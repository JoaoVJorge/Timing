import "package:help_out/core/services/http/http_status_code.dart";

abstract class AppError {
  const AppError(this.message);

  final String message;
}

class HttpError extends AppError {
  HttpError({required this.statusCode, required String message})
    : super(message);

  final HttpStatusCode statusCode;
}

class GenericAppError extends AppError {
  GenericAppError({required Object error, required StackTrace stackTrace})
    : super("Generic error: $error \n StackTrace: $stackTrace");
}

class SqlOperationAppError extends AppError {
  SqlOperationAppError({
    required String operation,
    required Object error,
    required StackTrace stackTrace,
  }) : super("Erro no Supabase ($operation): ${describe(error)}");

  static String describe(Object error) {
    final dynamic raw = error;
    final List<String> parts = [];

    void addField(String label, Object? Function() read) {
      try {
        final Object? value = read();
        if (value == null) {
          return;
        }
        final String text = value.toString().trim();
        if (text.isNotEmpty) {
          parts.add("$label=$text");
        }
      } catch (_) {
        return;
      }
    }

    addField("code", () => raw.code);
    addField("message", () => raw.message);
    addField("details", () => raw.details);
    addField("hint", () => raw.hint);

    if (parts.isEmpty) {
      parts.add(error.toString());
    }

    final String message = parts.join(" | ");
    return message.length <= 420 ? message : "${message.substring(0, 420)}...";
  }
}

class SerializationAppError extends AppError {
  SerializationAppError({required Object error, required StackTrace stackTrace})
    : super("Serialization error: $error \n StackTrace: $stackTrace");
}

class RouteArgumentError extends AppError {
  RouteArgumentError({
    required this.routeName,
    required this.expected,
    required this.actual,
  }) : super(
         "Route \"$routeName\" expected arguments of type $expected but "
         "received ${actual == null ? "null" : actual.runtimeType}.",
       );

  final String routeName;
  final Type expected;
  final Object? actual;
}
