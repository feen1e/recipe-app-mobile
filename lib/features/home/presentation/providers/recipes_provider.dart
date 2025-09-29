import "dart:developer";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../../core/network/dio_provider.dart";
import "../../data/models/post.dart";
import "../../data/repositories/recipes_repository.dart";

part "recipes_provider.g.dart";

@riverpod
RecipesRepository recipesRepository(Ref ref) {
  final dio = ref.read(dioProvider);
  return RecipesRepository(dio: dio);
}

@riverpod
class LatestRecipes extends _$LatestRecipes {
  @override
  Future<RecipesResponseDto> build() {
    final repository = ref.read(recipesRepositoryProvider);
    return repository.getLatestRecipes(limit: 10);
  }

  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore) return;

    try {
      ref.read(loadMoreStateProvider.notifier).setLoading(loading: true);

      final repository = ref.read(recipesRepositoryProvider);
      final nextPage = await repository.getLatestRecipes(cursor: currentState.nextCursor, limit: 10);

      final combinedRecipes = [...currentState.recipes, ...nextPage.recipes];

      final updatedResponse = RecipesResponseDto(
        recipes: combinedRecipes,
        nextCursor: nextPage.nextCursor,
        hasMore: nextPage.hasMore,
      );

      state = AsyncValue.data(updatedResponse);
    } on Exception catch (e) {
      log("Error loading more recipes: $e");
    } finally {
      ref.read(loadMoreStateProvider.notifier).setLoading(loading: false);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue<RecipesResponseDto>.loading();
    try {
      final repository = ref.read(recipesRepositoryProvider);
      final response = await repository.getLatestRecipes(limit: 10);
      state = AsyncValue.data(response);
    } on Exception catch (e, stackTrace) {
      state = AsyncValue<RecipesResponseDto>.error(e, stackTrace);
    }
  }
}

@riverpod
class LoadMoreState extends _$LoadMoreState {
  @override
  bool build() => false;

  void setLoading({required bool loading}) {
    state = loading;
  }
}
