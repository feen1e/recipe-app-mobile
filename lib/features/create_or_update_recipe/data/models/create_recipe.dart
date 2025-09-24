import "package:freezed_annotation/freezed_annotation.dart";

part "create_recipe.freezed.dart";
part "create_recipe.g.dart";

@freezed
abstract class CreateRecipeRequest with _$CreateRecipeRequest {
  const factory CreateRecipeRequest({
    required String title,
    String? description,
    required List<String> ingredients,
    required List<String> steps,
    String? imageUrl,
  }) = _CreateRecipeRequest;

  factory CreateRecipeRequest.fromJson(Map<String, dynamic> json) => _$CreateRecipeRequestFromJson(json);
}

@freezed
abstract class UpdateRecipeRequest with _$UpdateRecipeRequest {
  const factory UpdateRecipeRequest({
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? steps,
    String? imageUrl,
  }) = _UpdateRecipeRequest;

  factory UpdateRecipeRequest.fromJson(Map<String, dynamic> json) => _$UpdateRecipeRequestFromJson(json);
}

@freezed
abstract class RecipeResponse with _$RecipeResponse {
  const factory RecipeResponse({
    required String id,
    required String title,
    String? description,
    required List<String> ingredients,
    required List<String> steps,
    String? imageUrl,
    @Default(0.0) double avgRating,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String authorId,
  }) = _RecipeResponse;

  factory RecipeResponse.fromJson(Map<String, dynamic> json) => _$RecipeResponseFromJson(json);
}
