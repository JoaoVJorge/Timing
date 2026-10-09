import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/errors/app_error.dart";

void main() {
  AppError classify(Object error) =>
      toAppError(error, StackTrace.empty, operation: "rpc public.something");

  group("a backend that could not be reached is an offline error", () {
    test("a timeout", () {
      expect(classify(TimeoutException("slow")), isA<OfflineError>());
    });

    test("no route to the host", () {
      expect(classify(const SocketException("down")), isA<OfflineError>());
    });

    test("a request that never got an answer", () {
      expect(classify(http.ClientException("reset")), isA<OfflineError>());
    });

    test("a gateway failing in front of the database", () {
      expect(
        classify(const PostgrestException(message: "bad gateway", code: "502")),
        isA<OfflineError>(),
      );
    });

    test("an auth request that may be retried", () {
      expect(
        classify(AuthRetryableFetchException(message: "fetch failed")),
        isA<OfflineError>(),
      );
    });
  });

  group("an answer that refuses the action is a rejection", () {
    test("the database's own error keeps its code", () {
      final AppError error = classify(
        const PostgrestException(message: "duplicate key", code: "23505"),
      );

      expect(error, isA<RejectedError>());
      expect((error as RejectedError).code, "23505");
    });

    test("an auth answer", () {
      expect(
        classify(const AuthException("Invalid code", statusCode: "403")),
        isA<RejectedError>(),
      );
    });
  });

  test("anything else is unexpected and keeps what was being attempted", () {
    final AppError error = classify(StateError("no row"));

    expect(error, isA<UnexpectedError>());
    expect(error.operation, "rpc public.something");
    expect(error.debugDescription, contains("no row"));
  });

  test("an error that is already typed passes through untouched", () {
    const SignedOutError original = SignedOutError();

    expect(classify(original), same(original));
  });

  group("guardBackendCall", () {
    test("hands the value through", () async {
      final result = await guardBackendCall(() async => 7);

      expect(result.getOrElse(() => 0), 7);
    });

    test("reports a failure as a typed error and tells the caller", () async {
      Object? seen;

      final result = await guardBackendCall<int>(
        () async => throw TimeoutException("slow"),
        onError: (error, _) => seen = error,
      );

      expect(result.fold((error) => error, (_) => null), isA<OfflineError>());
      expect(seen, isA<TimeoutException>());
    });

    test("also catches a call that throws before returning a future", () async {
      final result = await guardBackendCall<int>(
        () => throw StateError("not configured"),
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
