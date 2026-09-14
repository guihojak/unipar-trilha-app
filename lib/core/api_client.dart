import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';

typedef TokenReader = Future<String?> Function();
typedef UnauthorizedHandler = Future<void> Function();

class ApiClient {
  ApiClient({Dio? dio}) : dio = dio ?? Dio(_defaultOptions) {
    this.dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  static final ApiClient shared = ApiClient();

  static final BaseOptions _defaultOptions = BaseOptions(
    baseUrl: ConstantsApi.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    headers: const {'Accept': Headers.jsonContentType},
  );

  final Dio dio;
  TokenReader _tokenReader = _emptyToken;
  UnauthorizedHandler _unauthorizedHandler = _ignoreUnauthorized;

  void configureAuthentication({
    required TokenReader tokenReader,
    required UnauthorizedHandler onUnauthorized,
  }) {
    _tokenReader = tokenReader;
    _unauthorizedHandler = onUnauthorized;
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicEndpoint(options.path)) {
      final token = await _tokenReader();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401 &&
        !_isPublicEndpoint(error.requestOptions.path)) {
      await _unauthorizedHandler();
    }
    handler.next(error);
  }

  static bool _isPublicEndpoint(String path) {
    final normalizedPath = Uri.tryParse(path)?.path ?? path;
    return normalizedPath == ConstantsApi.login ||
        normalizedPath == ConstantsApi.health;
  }

  static Future<String?> _emptyToken() async => null;
  static Future<void> _ignoreUnauthorized() async {}
}
