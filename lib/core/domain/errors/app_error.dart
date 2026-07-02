import "package:help_out/core/services/http/http_status_code.dart";

abstract class AppError {
  const AppError(this.message);

  final String message;
}

class HttpError extends AppError {
  HttpError({required this.statusCode, required String message}) : super(message);

  final HttpStatusCode statusCode;
}

class GenericAppError extends AppError {
  GenericAppError({required Object error, required StackTrace stackTrace})
    : super("Generic error: $error \n StackTrace: $stackTrace");
}

class SerializationAppError extends AppError {
  SerializationAppError({required Object error, required StackTrace stackTrace})
    : super("Serialization error: $error \n StackTrace: $stackTrace");
}
