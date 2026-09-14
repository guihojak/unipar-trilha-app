import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_error.dart';

void main() {
  test('lê detail e erros de campo do Problem Details', () {
    final request = RequestOptions(path: '/trilhas');
    final exception = DioException(
      requestOptions: request,
      response: Response<Object?>(
        requestOptions: request,
        statusCode: 400,
        data: {
          'detail': 'Um ou mais campos são inválidos.',
          'errors': {'titulo': 'título é obrigatório'},
        },
      ),
    );

    final error = ApiError.fromDioException(exception);
    expect(error.statusCode, 400);
    expect(error.message, 'Um ou mais campos são inválidos.');
    expect(error.fieldErrors['titulo'], 'título é obrigatório');
  });

  test('produz mensagem compreensível para timeout', () {
    final error = ApiError.fromDioException(
      DioException(
        requestOptions: RequestOptions(path: '/health'),
        type: DioExceptionType.receiveTimeout,
      ),
    );

    expect(error.isTimeout, isTrue);
    expect(error.message, contains('demorou'));
  });

  test('permite mensagem de credencial específica no login', () {
    final request = RequestOptions(path: '/auth/login');
    final error = ApiError.fromDioException(
      DioException(
        requestOptions: request,
        response: Response<Object?>(requestOptions: request, statusCode: 401),
      ),
      unauthorizedMessage: 'Login ou senha inválidos.',
    );

    expect(error.message, 'Login ou senha inválidos.');
  });
}
