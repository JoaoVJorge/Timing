import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

/// Logs every request the backend client makes (reads and writes alike) as one
/// compact block in the debug console:
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
    final String? requestBody = request is http.Request ? request.body : null;
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
          requestBody: requestBody,
          responseBody: utf8.decode(bytes, allowMalformed: true),
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
          requestBody: requestBody,
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

const int _maxStringLength = 48;
const int _maxLineLength = 320;
const int _previewRows = 2;

/// Keys whose values must never reach a log.
final RegExp _secretKey = RegExp(
  r"password|token|secret|authorization|apikey|api_key",
  caseSensitive: false,
);

/// Builds the console block for one request. Exposed for tests.
///
/// Authentication and storage traffic only gets its summary line: their bodies
/// carry credentials, one-time codes and tokens.
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
  final String path = uri.path;
  final bool isSensitive =
      path.startsWith("/auth/") || path.startsWith("/storage/");
  final bool failed = error != null || (statusCode ?? 0) >= 400;
  final String glyph = failed ? "✗" : "✓";
  final String status = error != null ? "no response" : "$statusCode";

  final StringBuffer block = StringBuffer(
    "┌ $glyph ${method.toUpperCase().padRight(6)} "
    "${_describe(method, uri, preferHeader)} · $status · "
    "${elapsed.inMilliseconds} ms",
  );

  if (!isSensitive) {
    final String? sentLine = _bodyLine(requestBody);
    if (sentLine != null) {
      block.write("\n│ → $sentLine");
    }
  }
  if (error != null) {
    block.write("\n│ ✗ ${_clip(error.toString())}");
  } else if (!isSensitive) {
    block.write("\n│ ← ${_responseLine(responseBody, failed: failed)}");
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

String? _bodyLine(String? body) {
  if (body == null || body.isEmpty) {
    return null;
  }
  return _clip(_compact(_decode(body)));
}

String _responseLine(String? body, {required bool failed}) {
  if (body == null || body.isEmpty) {
    return "(empty)";
  }
  final Object? decoded = _decode(body);
  if (failed || decoded is! List) {
    return _clip(_compact(decoded));
  }
  if (decoded.isEmpty) {
    return "0 rows";
  }
  final String rows = decoded.length == 1 ? "1 row" : "${decoded.length} rows";
  final List<Object?> preview = decoded.take(_previewRows).toList();
  final String more = decoded.length > _previewRows ? ", …" : "";
  final String shown = _compact(preview);
  return _clip("$rows · ${shown.substring(0, shown.length - 1)}$more]");
}

Object? _decode(String body) {
  try {
    return _redact(jsonDecode(body));
  } on FormatException {
    return _clip(body);
  }
}

/// Copies [value] hiding secrets and shortening long strings (base64 photos).
Object? _redact(Object? value, [String? key]) {
  if (key != null && _secretKey.hasMatch(key)) {
    return "‹hidden›";
  }
  if (value is String) {
    return value.length <= _maxStringLength
        ? value
        : "${value.substring(0, _maxStringLength)}…(${value.length} chars)";
  }
  if (value is Map) {
    return {
      for (final MapEntry<dynamic, dynamic> entry in value.entries)
        entry.key.toString(): _redact(entry.value, entry.key.toString()),
    };
  }
  if (value is Iterable) {
    return value.map(_redact).toList();
  }
  return value;
}

String _compact(Object? value) => value is String ? value : jsonEncode(value);

String _clip(String text) => text.length <= _maxLineLength
    ? text
    : "${text.substring(0, _maxLineLength)}…";
