import "package:freezed_annotation/freezed_annotation.dart";

part "recipe.freezed.dart";
part "recipe.g.dart";

@freezed
abstract class RecipeDetailsDto with _$RecipeDetailsDto {
  const factory RecipeDetailsDto({
    required String id,
    required String title,
    String? description,
    required List<String> ingredients,
    required List<String> steps,
    String? imageUrl,
    required String authorId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RecipeDetailsDto;

  factory RecipeDetailsDto.fromJson(Map<String, dynamic> json) => _$RecipeDetailsDtoFromJson(json);
}
