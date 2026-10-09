import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/profile_sync_data_source.dart";
import "package:timing/core/data/repositories/profile_sync_repository.dart";
import "package:timing/core/services/log/app_logger_service.dart";

import "../../../support/supabase_test_harness.dart";

ProfileSyncRepository _repository(TestBackend backend) => ProfileSyncRepository(
  profileSyncDataSource: ProfileSyncDataSource(
    supabaseService: TestSupabaseService(backend.client),
    logger: AppLoggerService(),
  ),
);

void main() {
  test("reads the profile and its private data at the same time", () async {
    final Completer<void> privateDataRequested = Completer<void>();
    final backend = TestBackend((request) async {
      if (request.url.path.endsWith("/profile_private_data")) {
        privateDataRequested.complete();
        return jsonResponse(request, [
          {
            "email": "ana@example.com",
            "phone_number": null,
            "birth_date": null,
          },
        ]);
      }
      await privateDataRequested.future.timeout(const Duration(seconds: 5));
      return jsonResponse(request, [
        {"id": "user-1", "user_name": "Ana", "friend_code": "ABC123"},
      ]);
    });
    addTearDown(backend.dispose);

    final result = await _repository(backend).getCurrentProfile();

    final profile = result.fold((_) => fail("expected Right"), (p) => p);
    expect(profile?.userName, "Ana");
    expect(profile?.friendCode, "ABC123");
    expect(profile?.email, "ana@example.com");
  });

  test("an account without a profile row reads as no profile", () async {
    final backend = TestBackend((request) async => jsonResponse(request, []));
    addTearDown(backend.dispose);

    final result = await _repository(backend).getCurrentProfile();

    expect(result.fold((_) => fail("expected Right"), (p) => p), isNull);
  });

  test("deletes the account through the delete_my_account rpc", () async {
    final List<String> seen = <String>[];
    final backend = TestBackend((request) async {
      seen.add("${request.method} ${request.url.path} ${request.url.query}");
      return jsonResponse(request, []);
    });
    addTearDown(backend.dispose);

    final result = await _repository(backend).deleteAccount();

    expect(result.isRight(), isTrue);
    expect(seen, hasLength(1));
    expect(seen.single, startsWith("POST "));
    expect(seen.single, contains("/rpc/delete_my_account"));
  });

  test("a failed account deletion surfaces as an error", () async {
    final backend = TestBackend(
      (request) async => jsonResponse(request, {"message": "boom"}, 500),
    );
    addTearDown(backend.dispose);

    final result = await _repository(backend).deleteAccount();

    expect(result.isLeft(), isTrue);
  });
}
