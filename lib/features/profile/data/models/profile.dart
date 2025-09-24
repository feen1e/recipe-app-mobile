import "package:freezed_annotation/freezed_annotation.dart";

part "profile.freezed.dart";
part "profile.g.dart";

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({required String id, required String title, String? description, String? imageUrl}) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}

@freezed
abstract class Rating with _$Rating {
  const factory Rating({required String id, required int stars, String? review, required String recipeName}) = _Rating;

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String username,
    String? bio,
    String? avatarUrl,
    @Default(0) int recipesCount,
    @Default(0) int ratingsCount,
    @Default([]) List<Recipe> recipes,
    @Default([]) List<Rating> ratings,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
