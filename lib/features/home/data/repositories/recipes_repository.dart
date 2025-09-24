import "dart:developer";

import "package:dio/dio.dart";
import "../../../../core/constants/api_endpoints.dart";
import "../models/post.dart";

class RecipesRepository {
  final Dio _dio;

  RecipesRepository({required Dio dio}) : _dio = dio;

  Future<RecipesResponseDto> getLatestRecipes({String? cursor, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (cursor != null) {
        queryParams["cursor"] = cursor;
      }

      if (limit != null) {
        queryParams["limit"] = limit;
      }

      log("Fetching latest recipes with params: $queryParams");
      log("Endpoint: ${ApiEndpoints.recipesLatest}");

      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.recipesLatest, queryParameters: queryParams);

      log("Latest recipes response status: ${response.statusCode}");
      log("Latest recipes response data: ${response.data}");

      if (response.data != null) {
        return RecipesResponseDto.fromJson(response.data!);
      } else {
        throw Exception("Failed to fetch latest recipes: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to fetch latest recipes";

      log("DioException type: ${e.type}");
      log("DioException message: ${e.message}");
      log("DioException response: ${e.response?.data}");

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to fetch latest recipes ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to fetch latest recipes: ${e.message}";
      } else {
        errorMessage = "Failed to fetch latest recipes: Network error - ${e.type}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      log("Unexpected error: $e");
      throw Exception("Failed to fetch latest recipes: Unexpected error - $e");
    }
  }
}
