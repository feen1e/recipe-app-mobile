import "dart:developer";

import "package:dio/dio.dart";
import "../../../../core/config/app_config.dart";
import "../../../../core/constants/api_endpoints.dart";
import "../models/auth_token.dart";
import "../models/login_request.dart";
import "../models/register_request.dart";

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
      final loginData = LoginRequest(identifier: identifier, password: password).toJson();
      log("Login request data: $loginData");
      log("Login endpoint: ${ApiEndpoints.authLogin}");
      log("Base URL: ${_dio.options.baseUrl}");

      final response = await _dio.post<Map<String, dynamic>>(ApiEndpoints.authLogin, data: loginData);

      log("Login response status: ${response.statusCode}");
      log("Login response data: ${response.data}");

      if (response.data != null) {
        return AuthToken.fromJson(response.data!);
      } else {
        throw Exception("Login failed: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Login failed";

      log("DioException type: ${e.type}");
      log("DioException message: ${e.message}");
      log("DioException response: ${e.response?.data}");

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Login failed ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Login failed: ${e.message}";
      } else {
        errorMessage = "Login failed: Network error - ${e.type}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      log("Unexpected error: $e");
      throw Exception("Login failed: Unexpected error - $e");
    }
  }

  Future<AuthToken> register({required String username, required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authRegister,
        data: RegisterRequest(username: username, email: email, password: password).toJson(),
      );

      if (response.data != null) {
        return AuthToken.fromJson(response.data!);
      } else {
        throw Exception("Registration failed with status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to register: ${e.message}");
    }
  }
}
