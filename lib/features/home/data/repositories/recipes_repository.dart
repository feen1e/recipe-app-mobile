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

      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.recipesLatest, queryParameters: queryParams);

      if (response.data != null) {
        return RecipesResponseDto.fromJson(response.data!);
      } else {
        throw Exception("Failed to fetch latest recipes: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to fetch latest recipes";

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
      throw Exception("Failed to fetch latest recipes: Unexpected error - $e");
    }
  }
}
