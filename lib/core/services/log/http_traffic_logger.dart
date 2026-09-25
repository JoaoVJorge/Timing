import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

/// Logs request metadata in debug builds without ever logging bodies. REST
/// payloads contain profile data, notes, schedules and activity history, so
/// even a redacted preview is too easy to leak through adb/IDE logs.
///
///     ┌ ✓ POST   upsert  activity_entries?on_conflict=id · 201 · 184 ms
///     │ → {"id":"5f1c…","seconds":60,"pages":0}
///     │ ← (empty)
///     └
///
/// Debug builds only: [SupabaseService] installs it behind `kDebugMode`.
class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient(this._inner, {void Function(String block)? sink})
    : _sink = sink ?? debugPrint;

  final http.Client _inner;
  final void Function(String block) _sink;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final http.StreamedResponse response = await _inner.send(request);
      final List<int> bytes = await response.stream.toBytes();
      stopwatch.stop();
      _sink(
        formatHttpExchange(
          method: request.method,
          uri: request.url,
          preferHeader: request.headers["Prefer"] ?? request.headers["prefer"],
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        ),
      );
      return http.StreamedResponse(
        http.ByteStream.fromBytes(bytes),
        response.statusCode,
        contentLength: bytes.length,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error) {
      stopwatch.stop();
      _sink(
        formatHttpExchange(
          method: request.method,
          uri: request.url,
          preferHeader: request.headers["Prefer"] ?? request.headers["prefer"],
          elapsed: stopwatch.elapsed,
          error: error,
        ),
      );
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

/// Builds the console block for one request. Exposed for tests.
String formatHttpExchange({
  required String method,
  required Uri uri,
  required Duration elapsed,
  int? statusCode,
  String? preferHeader,
  String? requestBody,
  String? responseBody,
  Object? error,
}) {
  final bool failed = error != null || (statusCode ?? 0) >= 400;
  final String glyph = failed ? "✗" : "✓";
  final String status = error != null ? "no response" : "$statusCode";

  final StringBuffer block = StringBuffer(
    "┌ $glyph ${method.toUpperCase().padRight(6)} "
    "${_describe(method, uri, preferHeader)} · $status · "
    "${elapsed.inMilliseconds} ms",
  );

  if (error != null) {
    block.write("\n│ ✗ ${error.runtimeType}");
  }
  block.write("\n└");
  return block.toString();
}

/// "upsert  activity_entries?on_conflict=id" instead of a bare URL.
String _describe(String method, Uri uri, String? preferHeader) {
  final String path = uri.path;
  final String query = uri.hasQuery
      ? "?${Uri.decodeQueryComponent(uri.query)}"
      : "";
  if (path.startsWith("/rest/v1/rpc/")) {
    return "rpc     ${path.substring("/rest/v1/rpc/".length)}${_clipQuery(query)}";
  }
  if (path.startsWith("/rest/v1/")) {
    final String target = path.substring("/rest/v1/".length);
    final String verb = switch (method.toUpperCase()) {
      "GET" || "HEAD" => "select ",
      "POST" =>
        (preferHeader ?? "").contains("resolution=merge-duplicates")
            ? "upsert "
            : "insert ",
      "PATCH" || "PUT" => "update ",
      "DELETE" => "delete ",
      _ => "       ",
    };
    return "$verb $target${_clipQuery(query)}";
  }
  return "${path.replaceFirst(RegExp(r"^/"), "")}${_clipQuery(query)}";
}

String _clipQuery(String query) =>
    query.length <= 90 ? query : "${query.substring(0, 90)}…";
