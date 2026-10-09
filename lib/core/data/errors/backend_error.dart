import "dart:async";
import "dart:io";

import "package:dartz/dartz.dart";
import "package:http/http.dart" as http;
import "package:supabase_flutter/supabase_flutter.dart"
    show AuthException, AuthRetryableFetchException, PostgrestException;
import "package:timing/core/domain/errors/app_error.dart";

/// Turns whatever a backend call threw into the [AppError] that explains it.
///
/// This is the single place that decides what a failure means for the user:
/// data sources throw the raw exception and repositories pass it here.
AppError toAppError(Object error, StackTrace stackTrace, {String? operation}) {
  if (error is AppError) {
    return error;
  }
  if (_isBackendUnreachable(error)) {
    return OfflineError(
      operation: operation,
      cause: describeBackendError(error),
      stackTrace: stackTrace,
    );
  }
  if (error is PostgrestException) {
    return RejectedError(
      code: error.code,
      operation: operation,
      cause: describeBackendError(error),
      stackTrace: stackTrace,
    );
  }
  if (error is AuthException) {
    return RejectedError(
      code: error.code ?? error.statusCode,
      operation: operation,
      cause: describeBackendError(error),
      stackTrace: stackTrace,
    );
  }
  return UnexpectedError(
    operation: operation,
    cause: error,
    stackTrace: stackTrace,
  );
}

/// Runs a backend call and reports a failure as a typed [AppError] instead of
/// letting the exception escape.
Future<Either<AppError, T>> guardBackendCall<T>(
  Future<T> Function() call, {
  String? operation,
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    return Right(await call());
  } catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    return Left(toAppError(error, stackTrace, operation: operation));
  }
}

bool _isBackendUnreachable(Object error) =>
    error is TimeoutException ||
    error is SocketException ||
    error is http.ClientException ||
    error is AuthRetryableFetchException ||
    error is PostgrestException && _isGatewayFailure(error);

/// A response that is not PostgREST's own JSON error carries the HTTP status
/// as its code, so a 5xx there is the gateway failing, not an answer from the
/// database. A SQLSTATE is five characters and may be all digits too (`23505`),
/// so only a three-digit code is read as a status.
bool _isGatewayFailure(PostgrestException error) {
  final String code = error.code ?? "";
  final int? status = code.length == 3 ? int.tryParse(code) : null;
  return status != null && status >= 500;
}

/// The fields a Supabase exception carries, joined into one line for the log
/// and for recognising specific backend codes.
String describeBackendError(Object error) {
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
