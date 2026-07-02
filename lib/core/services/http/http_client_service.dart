import "package:dartz/dartz.dart";
import "package:dio/dio.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/http/app_http_request.dart";
import "package:help_out/core/services/http/http_status_code.dart";

class HttpClientService {
  HttpClientService({required this._dio});

  final Dio _dio;

  Future<Either<AppError, Map<String, dynamic>>> request(AppHttpRequest request) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.request(
        request.path,
        data: request.body,
        queryParameters: request.queryParameters,
        options: Options(method: request.method.label, headers: request.headers, validateStatus: (_) => true),
      );

      return handleResponse(response);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Either<AppError, Map<String, dynamic>> handleResponse(Response<Map<String, dynamic>> response) {
    final Map<String, dynamic> data = response.data ?? {};
    final HttpStatusCode statusCode = HttpStatusCode.fromInt(response.statusCode);

    if (statusCode.isSuccess) {
      return Right(data["data"] as Map<String, dynamic>? ?? {});
    }

    final String errorMessage = data["message"] as String? ?? "Unknown error";

    return Left(HttpError(statusCode: statusCode, message: errorMessage));
  }
}
