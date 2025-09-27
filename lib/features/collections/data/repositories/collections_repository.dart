import "dart:developer";

import "package:dio/dio.dart";
import "../../../../core/constants/api_endpoints.dart";
import "../../../recipe_details/data/models/recipe.dart";
import "../models/collection.dart";

class CollectionsRepository {
  final Dio _dio;

  CollectionsRepository({required Dio dio}) : _dio = dio;

  Future<List<RecipeDetailsDto>> getFavorites(String username) async {
    try {
      log("Fetching favorites for username: $username");
      log("Endpoint: ${ApiEndpoints.favorites}/$username");

      final response = await _dio.get<List<dynamic>>("${ApiEndpoints.favorites}/$username");

      log("Favorites response status: ${response.statusCode}");
      log("Favorites response data: ${response.data}");

      if (response.data != null) {
        return response.data!.map((json) => RecipeDetailsDto.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception("Failed to fetch favorites: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to fetch favorites";

      log("DioException type: ${e.type}");
      log("DioException message: ${e.message}");
      log("DioException response: ${e.response?.data}");

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to fetch favorites ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to fetch favorites: ${e.message}";
      }

      log("Error fetching favorites: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      log("Unexpected error fetching favorites: $e");
      throw Exception("Failed to fetch favorites: $e");
    }
  }

  Future<List<CollectionDto>> getCollections(String username) async {
    try {
      log("Fetching collections for username: $username");
      log("Endpoint: ${ApiEndpoints.collectionsUser}/$username");

      final response = await _dio.get<List<dynamic>>("${ApiEndpoints.collectionsUser}/$username");

      log("Collections response status: ${response.statusCode}");
      log("Collections response data: ${response.data}");

      if (response.data != null) {
        return response.data!.map((json) => CollectionDto.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception("Failed to fetch collections: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to fetch collections";

      log("DioException type: ${e.type}");
      log("DioException message: ${e.message}");
      log("DioException response: ${e.response?.data}");

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to fetch collections ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to fetch collections: ${e.message}";
      }

      log("Error fetching collections: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      log("Unexpected error fetching collections: $e");
      throw Exception("Failed to fetch collections: $e");
    }
  }

  Future<void> addFavorite(String recipeId) async {
    try {
      await _dio.post<Map<String, dynamic>>("${ApiEndpoints.favorites}/$recipeId");
    } on DioException catch (e) {
      log("Failed to add favorite: ${e.message}");
    }
  }

  Future<void> removeFavorite(String recipeId) async {
    try {
      await _dio.delete<Map<String, dynamic>>("${ApiEndpoints.favorites}/$recipeId");
    } on DioException catch (e) {
      log("Failed to remove favorite: ${e.message}");
    }
  }

  Future<void> createCollection({required String name, String? description, List<String>? recipeIds}) async {
    try {
      final body = <String, dynamic>{"name": name, "description": ?description};

      final response = await _dio.post<Map<String, dynamic>>(ApiEndpoints.collectionsCRUD, data: body);

      final createdId = response.data != null ? (response.data!["id"] as String?) : null;

      if (recipeIds != null && recipeIds.isNotEmpty && createdId != null) {
        for (final recipeId in recipeIds) {
          try {
            await _dio.post<Map<String, dynamic>>(
              "${ApiEndpoints.collectionsCRUD}/$createdId/recipes",
              data: {"recipeId": recipeId},
            );
          } on DioException catch (e) {
            log("Failed to add recipe $recipeId to collection $createdId: ${e.message}");
          }
        }
      }
    } on DioException catch (e) {
      log("Failed to create collection: ${e.message}");
      rethrow;
    }
  }
}
