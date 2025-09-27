import "dart:developer";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../../core/network/dio_provider.dart";
import "../../../auth/presentation/providers/auth_provider.dart";
import "../../../recipe_details/data/models/recipe.dart";
import "../../data/models/collection.dart";
import "../../data/repositories/collections_repository.dart";

part "collections_provider.g.dart";

@riverpod
CollectionsRepository collectionsRepository(Ref ref) {
  final dio = ref.read(dioProvider);
  return CollectionsRepository(dio: dio);
}

@riverpod
class Favorites extends _$Favorites {
  @override
  Future<List<RecipeDetailsDto>> build() async {
    final repository = ref.read(collectionsRepositoryProvider);
    final username = await ref.read(currentUsernameProvider.future);

    if (username == null) {
      throw Exception("User not authenticated");
    }

    final result = await repository.getFavorites(username);
    return result;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(collectionsRepositoryProvider);
      final username = await ref.read(currentUsernameProvider.future);

      if (username == null) {
        throw Exception("User not authenticated");
      }

      final favorites = await repository.getFavorites(username);
      state = AsyncData(favorites);
    } on Exception catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

@riverpod
class Collections extends _$Collections {
  @override
  Future<List<CollectionDto>> build() async {
    final repository = ref.read(collectionsRepositoryProvider);
    final username = await ref.read(currentUsernameProvider.future);

    if (username == null) {
      throw Exception("User not authenticated");
    }

    final result = await repository.getCollections(username);
    return result;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(collectionsRepositoryProvider);
      final username = await ref.read(currentUsernameProvider.future);

      if (username == null) {
        throw Exception("User not authenticated");
      }

      final collections = await repository.getCollections(username);
      state = AsyncData(collections);
    } on Exception catch (e, stackTrace) {
      log("Error refreshing collections: $e");
      state = AsyncError(e, stackTrace);
    }
  }
}
