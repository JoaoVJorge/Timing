enum HttpStatusCode {
  ok(200),
  created(201),
  accepted(202),
  noContent(204),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  conflict(409),
  unprocessableEntity(422),
  tooManyRequests(429),
  internalServerError(500),
  badGateway(502),
  serviceUnavailable(503);

  const HttpStatusCode(this.code);

  final int code;

  static HttpStatusCode fromInt(int? code) => HttpStatusCode.values.firstWhere(
    (httpStatusCode) => httpStatusCode.code == code,
    orElse: () => HttpStatusCode.internalServerError,
  );

  bool get isSuccess => switch (this) {
    HttpStatusCode.ok => true,
    HttpStatusCode.created => true,
    HttpStatusCode.accepted => true,
    HttpStatusCode.noContent => true,
    _ => false,
  };
}
