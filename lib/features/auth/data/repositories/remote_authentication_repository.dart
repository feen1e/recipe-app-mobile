import "package:dio/dio.dart";
import "../../../../core/config/app_config.dart";
import "../../../../core/constants/api_endpoints.dart";
import "../models/auth_token.dart";
import "../models/login_request.dart";

class RemoteAuthenticationRepository {
  final Dio _dio;

  RemoteAuthenticationRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );

  Future<AuthToken> login({required String identifier, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authLogin,
        data: LoginRequest(identifier: identifier, password: password).toJson(),
      );

      if (response.data != null) {
        return AuthToken.fromJson(response.data!);
      } else {
        throw Exception("Failed to login");
      }
    } on DioException catch (e) {
      throw Exception("Failed to login: ${e.message}");
    }
  }
}
