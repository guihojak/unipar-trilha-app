import 'package:dio/dio.dart';

class ApiError implements Exception {
  const ApiError({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
    this.isTimeout = false,
    this.isConnectionError = false,
  });

  final int? statusCode;
  final String message;
  final Map<String, String> fieldErrors;
  final bool isTimeout;
  final bool isConnectionError;

  factory ApiError.fromDioException(
    DioException exception, {
    String? unauthorizedMessage,
  }) {
    final statusCode = exception.response?.statusCode;
    final data = exception.response?.data;
    final problem = data is Map ? data : const <String, dynamic>{};
    final detail = problem['detail'];
    final timeout = switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => true,
      _ => false,
    };
    final connectionError = exception.type == DioExceptionType.connectionError;

    String message;
    if (detail is String && detail.trim().isNotEmpty) {
      message = detail;
    } else if (timeout) {
      message = 'O servidor demorou para responder. Tente novamente.';
    } else if (connectionError) {
      message = 'Não foi possível conectar ao servidor.';
    } else {
      message = switch (statusCode) {
        400 => 'A requisição contém dados inválidos.',
        401 => unauthorizedMessage ?? 'Sua sessão é inválida ou expirou.',
        403 => 'Você não tem permissão para acessar este recurso.',
        404 => 'O recurso solicitado não foi encontrado.',
        409 => 'A operação não pôde ser concluída devido a um conflito.',
        _ => 'Ocorreu um erro de comunicação com o servidor.',
      };
    }

    return ApiError(
      statusCode: statusCode,
      message: message,
      fieldErrors: _parseFieldErrors(problem['errors']),
      isTimeout: timeout,
      isConnectionError: connectionError,
    );
  }

  static Map<String, String> _parseFieldErrors(Object? value) {
    if (value is! Map) return const {};
    return value.map((key, error) {
      final message = error is Iterable ? error.join(', ') : error.toString();
      return MapEntry(key.toString(), message);
    });
  }

  @override
  String toString() => message;
}
