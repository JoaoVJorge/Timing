import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:timing/core/services/log/http_traffic_logger.dart";

Uri _rest(String path, [Map<String, String>? query]) =>
    Uri.https("proj.supabase.co", "/rest/v1/$path", query);

void main() {
  group("formatHttpExchange", () {
    test("shows a read with its row count", () {
      final block = formatHttpExchange(
        method: "GET",
        uri: _rest("group_members", {"select": "group_id"}),
        statusCode: 200,
        elapsed: const Duration(milliseconds: 96),
        responseBody: jsonEncode([
          {"group_id": "a"},
          {"group_id": "b"},
          {"group_id": "c"},
        ]),
      );

      expect(
        block,
        startsWith("┌ ✓ GET    select  group_members?select=group_id"),
      );
      expect(block, contains("200 · 96 ms"));
      expect(block, endsWith("\n└"));
    });

    test("labels writes by what they do, not just their verb", () {
      String header(String method, {String? prefer, Uri? uri}) =>
          formatHttpExchange(
            method: method,
            uri: uri ?? _rest("activity_entries"),
            preferHeader: prefer,
            statusCode: 201,
            elapsed: Duration.zero,
          ).split("\n").first;

      expect(header("POST"), contains("POST   insert  activity_entries"));
      expect(
        header("POST", prefer: "resolution=merge-duplicates,return=minimal"),
        contains("POST   upsert  activity_entries"),
      );
      expect(header("PATCH"), contains("PATCH  update  activity_entries"));
      expect(header("DELETE"), contains("DELETE delete  activity_entries"));
      expect(
        header("POST", uri: _rest("rpc/group_leaderboard_scores")),
        contains("POST   rpc     group_leaderboard_scores"),
      );
    });

    test("never shows REST request or response bodies", () {
      final block = formatHttpExchange(
        method: "POST",
        uri: _rest("activity_entries"),
        statusCode: 201,
        elapsed: Duration.zero,
        requestBody: jsonEncode({"seconds": 60, "pages": 0}),
      );

      expect(block, isNot(contains("seconds")));
      expect(block, isNot(contains("│ →")));
      expect(block, isNot(contains("│ ←")));
    });

    test("marks failures and prints the server's error", () {
      final block = formatHttpExchange(
        method: "POST",
        uri: _rest("friendships"),
        statusCode: 409,
        elapsed: Duration.zero,
        responseBody: jsonEncode({"code": "23505", "message": "duplicate key"}),
      );

      expect(block, startsWith("┌ ✗ POST"));
      expect(block, isNot(contains("23505")));
    });

    test("reports a request that never got a response", () {
      final block = formatHttpExchange(
        method: "GET",
        uri: _rest("groups"),
        elapsed: const Duration(seconds: 10),
        error: "TimeoutException",
      );

      expect(block, contains("no response"));
      expect(block, contains("│ ✗ String"));
    });

    test("does not log profile blobs or secrets", () {
      final block = formatHttpExchange(
        method: "POST",
        uri: _rest("profiles"),
        statusCode: 201,
        elapsed: Duration.zero,
        requestBody: jsonEncode({
          "profile_photo_base64": "A" * 5000,
          "access_token": "super-secret",
        }),
      );

      expect(block, isNot(contains("5000")));
      expect(block, isNot(contains("super-secret")));
      expect(block.length, lessThan(500));
    });

    test("never prints auth bodies", () {
      final block = formatHttpExchange(
        method: "POST",
        uri: Uri.https("proj.supabase.co", "/auth/v1/token", {
          "grant_type": "refresh_token",
        }),
        statusCode: 200,
        elapsed: Duration.zero,
        requestBody: jsonEncode({"refresh_token": "abc"}),
        responseBody: jsonEncode({"access_token": "def"}),
      );

      expect(block, isNot(contains("abc")));
      expect(block, isNot(contains("def")));
      expect(block, isNot(contains("│ →")));
      expect(block, isNot(contains("│ ←")));
    });
  });

  group("LoggingHttpClient", () {
    test("logs the exchange and hands the response through intact", () async {
      final logged = <String>[];
      final client = LoggingHttpClient(
        MockClient((request) async => http.Response('[{"a":1}]', 200)),
        sink: logged.add,
      );

      final response = await client.post(
        _rest("activity_entries"),
        headers: {"Prefer": "resolution=merge-duplicates"},
        body: jsonEncode({"seconds": 5}),
      );

      expect(response.statusCode, 200);
      expect(response.body, '[{"a":1}]');
      expect(logged, hasLength(1));
      expect(logged.single, contains("POST   upsert  activity_entries"));
      expect(logged.single, isNot(contains("seconds")));
      expect(logged.single, isNot(contains("│ ←")));
    });

    test("logs a failed request and rethrows", () async {
      final logged = <String>[];
      final client = LoggingHttpClient(
        MockClient((request) async => throw http.ClientException("offline")),
        sink: logged.add,
      );

      await expectLater(
        client.get(_rest("groups")),
        throwsA(isA<http.ClientException>()),
      );
      expect(logged.single, contains("no response"));
    });
  });
}
