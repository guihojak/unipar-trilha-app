import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';

class HealthResponse {
  const HealthResponse({required this.status});

  final String status;
  bool get isUp => status.toUpperCase() == 'UP';

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(status: json['status']?.toString() ?? '');
  }
}

class HealthService {
  HealthService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  Future<HealthResponse> consultar() async {
    try {
      final response = await _dio.get<Object?>(ConstantsApi.health);
      final data = response.data;
      if (data is! Map) {
        throw const ApiError(
          message: 'O health retornou uma resposta inválida.',
        );
      }
      final health = HealthResponse.fromJson(Map<String, dynamic>.from(data));
      if (!health.isUp) {
        throw const ApiError(message: 'A API não está disponível.');
      }
      return health;
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    }
  }
}
