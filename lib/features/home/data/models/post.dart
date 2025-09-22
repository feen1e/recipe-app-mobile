import "package:freezed_annotation/freezed_annotation.dart";

part "post.freezed.dart";
part "post.g.dart";

@freezed
abstract class AuthorDto with _$AuthorDto {
  const factory AuthorDto({required String username, String? avatarUrl}) = _AuthorDto;

  factory AuthorDto.fromJson(Map<String, dynamic> json) => _$AuthorDtoFromJson(json);
}

@freezed
abstract class LatestRecipeResponseDto with _$LatestRecipeResponseDto {
  const factory LatestRecipeResponseDto({
    required String id,
    required String title,
    String? description,
    required List<String> ingredients,
    required List<String> steps,
    String? imageUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    required AuthorDto author,
  }) = _LatestRecipeResponseDto;

  factory LatestRecipeResponseDto.fromJson(Map<String, dynamic> json) => _$LatestRecipeResponseDtoFromJson(json);
}

@freezed
abstract class LatestRecipesResponseDto with _$LatestRecipesResponseDto {
  const factory LatestRecipesResponseDto({
    required List<LatestRecipeResponseDto> recipes,
    String? nextCursor,
    required bool hasMore,
  }) = _LatestRecipesResponseDto;

  factory LatestRecipesResponseDto.fromJson(Map<String, dynamic> json) => _$LatestRecipesResponseDtoFromJson(json);
}
