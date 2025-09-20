import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../config/app_config.dart";

part "dio_provider.g.dart";

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true, responseHeader: false));

  return dio;
}
