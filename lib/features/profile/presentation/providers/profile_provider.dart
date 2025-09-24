import "dart:developer";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../../core/network/dio_provider.dart";
import "../../data/models/profile.dart";
import "../../data/repositories/profile_repository.dart";

part "profile_provider.g.dart";

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final dio = ref.read(dioProvider);
  return ProfileRepository(dio: dio);
}

@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<Profile> build(String username) {
    final repository = ref.read(profileRepositoryProvider);
    return repository.getUserProfile(username);
  }

  Future<void> refresh(String username) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(profileRepositoryProvider);
      final profile = await repository.getUserProfile(username);
      state = AsyncValue.data(profile);
    } on Exception catch (e) {
      log("Error refreshing user profile: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

@riverpod
class UserRecipes extends _$UserRecipes {
  @override
  Future<List<Recipe>> build(String username) {
    final repository = ref.read(profileRepositoryProvider);
    return repository.getUserRecipes(username);
  }

  Future<void> refresh(String username) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(profileRepositoryProvider);
      final recipes = await repository.getUserRecipes(username);
      state = AsyncValue.data(recipes);
    } on Exception catch (e) {
      log("Error refreshing user recipes: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

@riverpod
class UserRatings extends _$UserRatings {
  @override
  Future<List<Rating>> build(String username) {
    final repository = ref.read(profileRepositoryProvider);
    return repository.getUserRatings(username);
  }

  Future<void> refresh(String username) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(profileRepositoryProvider);
      final ratings = await repository.getUserRatings(username);
      state = AsyncValue.data(ratings);
    } on Exception catch (e) {
      log("Error refreshing user ratings: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

@riverpod
class CompleteProfile extends _$CompleteProfile {
  @override
  Future<CompleteProfileData> build(String username) async {
    final repository = ref.read(profileRepositoryProvider);

    final results = await Future.wait([
      repository.getUserProfile(username),
      repository.getUserRecipes(username),
      repository.getUserRatings(username),
    ]);

    return CompleteProfileData(
      profile: results[0] as Profile,
      recipes: results[1] as List<Recipe>,
      ratings: results[2] as List<Rating>,
    );
  }

  Future<void> refresh(String username) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(profileRepositoryProvider);
      final results = await Future.wait([
        repository.getUserProfile(username),
        repository.getUserRecipes(username),
        repository.getUserRatings(username),
      ]);

      final completeProfile = CompleteProfileData(
        profile: results[0] as Profile,
        recipes: results[1] as List<Recipe>,
        ratings: results[2] as List<Rating>,
      );

      state = AsyncValue.data(completeProfile);
    } on Exception catch (e) {
      log("Error refreshing complete profile: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class CompleteProfileData {
  final Profile profile;
  final List<Recipe> recipes;
  final List<Rating> ratings;

  CompleteProfileData({required this.profile, required this.recipes, required this.ratings});
}
