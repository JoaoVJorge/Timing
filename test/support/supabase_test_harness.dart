import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

/// A JSON response that carries its request, as a real client's would (the
/// Postgrest client reads `response.request`).
http.Response jsonResponse(
  http.Request request,
  Object? body, [
  int status = 200,
]) => http.Response(
  body == null ? "" : jsonEncode(body),
  status,
  request: request,
  headers: {"content-type": "application/json; charset=utf-8"},
);

/// A real [SupabaseClient] wired to an in-memory backend, so data sources are
/// exercised through the actual query builders and HTTP layer.
class TestBackend {
  TestBackend(this.handler) {
    client = SupabaseClient(
      "https://proj.supabase.co",
      "anon",
      httpClient: MockClient((request) => handler(request)),
    );
  }

  final Future<http.Response> Function(http.Request request) handler;
  late final SupabaseClient client;

  void dispose() => client.dispose();
}

class TestSupabaseService implements SupabaseService {
  TestSupabaseService(this._client, {this.userId = "user-1"});

  final SupabaseClient _client;
  final String? userId;

  @override
  String? get currentUserId => userId;

  @override
  SupabaseClient get requireClient => _client;

  @override
  bool get hasSignedInUser => userId != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MemoryStorage implements AppLocalStorageService {
  final Map<LocalStorageKeys, Object?> data = {};

  @override
  Future<T?> read<T>(LocalStorageKeys key) async => data[key] as T?;

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {
    data[key] = value;
  }

  @override
  Future<void> delete(LocalStorageKeys key) async {
    data.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
