import "package:help_out/core/domain/enums/http_method.dart";

abstract class AppHttpRequest {
  String get path;
  HttpMethod get method;
  Map<String, dynamic>? get body => null;
  Map<String, dynamic> get queryParameters => {};
  Map<String, dynamic> get headers => {};
}
