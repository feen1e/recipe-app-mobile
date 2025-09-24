import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../../core/network/dio_provider.dart";
import "../../data/models/recipe.dart";
import "../../data/repositories/recipe_details_repository.dart";

part "recipe_details_provider.g.dart";

@riverpod
RecipeDetailsRepository recipeDetailsRepository(Ref ref) {
  final dio = ref.read(dioProvider);
  return RecipeDetailsRepository(dio);
}

@riverpod
class RecipeDetails extends _$RecipeDetails {
  @override
  Future<RecipeDetailsDto> build(String recipeId) async {
    final repository = ref.read(recipeDetailsRepositoryProvider);
    final recipe = await repository.getRecipeById(recipeId);
    if (recipe == null) {
      throw Exception("Recipe not found");
    }
    return recipe;
  }

  Future<void> refresh(String recipeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(recipeDetailsRepositoryProvider);
      final recipe = await repo.getRecipeById(recipeId);
      if (recipe == null) {
        throw Exception("Recipe not found");
      }
      return recipe;
    });
  }
}
