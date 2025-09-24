import "package:freezed_annotation/freezed_annotation.dart";

part "post.freezed.dart";
part "post.g.dart";

@freezed
abstract class AuthorDto with _$AuthorDto {
  const factory AuthorDto({required String username, String? avatarUrl}) = _AuthorDto;

  factory AuthorDto.fromJson(Map<String, dynamic> json) => _$AuthorDtoFromJson(json);
}

@freezed
abstract class RecipeResponseDto with _$RecipeResponseDto {
  const factory RecipeResponseDto({
    required String id,
    required String title,
    String? description,
    required List<String> ingredients,
    required List<String> steps,
    String? imageUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    required AuthorDto author,
  }) = _RecipeResponseDto;

  factory RecipeResponseDto.fromJson(Map<String, dynamic> json) => _$RecipeResponseDtoFromJson(json);
}

@freezed
abstract class RecipesResponseDto with _$RecipesResponseDto {
  const factory RecipesResponseDto({
    required List<RecipeResponseDto> recipes,
    String? nextCursor,
    required bool hasMore,
  }) = _RecipesResponseDto;

  factory RecipesResponseDto.fromJson(Map<String, dynamic> json) => _$RecipesResponseDtoFromJson(json);
}
