import "package:dio/dio.dart";

import "../../../../core/constants/api_endpoints.dart";
import "../models/recipe.dart";

class RecipeDetailsRepository {
  final Dio _dio;

  RecipeDetailsRepository(this._dio);

  Future<RecipeDetailsDto?> getRecipeById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>("${ApiEndpoints.recipesCRUD}/$id");
    return response.data != null ? RecipeDetailsDto.fromJson(response.data!) : null;
  }

  Future<void> deleteRecipe(String id) async {
    await _dio.delete<Map<String, dynamic>>("${ApiEndpoints.recipesCRUD}/$id");
  }
}
