import "package:dio/dio.dart";

import "../../features/auth/data/repositories/authentication_repository.dart";

class AuthInterceptor extends Interceptor {
  final AuthenticationRepository authRepository;

  AuthInterceptor(this.authRepository);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await authRepository.getAccessToken();

    if (accessToken != null) {
      options.headers["Authorization"] = "Bearer $accessToken";
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await authRepository.logout();
    }

    super.onError(err, handler);
  }
}
