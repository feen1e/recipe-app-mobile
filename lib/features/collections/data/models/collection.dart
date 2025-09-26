import "package:freezed_annotation/freezed_annotation.dart";

part "collection.freezed.dart";
part "collection.g.dart";

@freezed
abstract class CollectionDto with _$CollectionDto {
  const factory CollectionDto({
    required String id,
    required String name,
    String? description,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CollectionDto;

  factory CollectionDto.fromJson(Map<String, dynamic> json) => _$CollectionDtoFromJson(json);
}

@freezed
abstract class FavoriteRecipeDto with _$FavoriteRecipeDto {
  const factory FavoriteRecipeDto({
    required String id,
    required String authorId,
    required String title,
    String? description,
    required List<String> ingredients,
    required List<String> steps,
    String? imageUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FavoriteRecipeDto;

  factory FavoriteRecipeDto.fromJson(Map<String, dynamic> json) => _$FavoriteRecipeDtoFromJson(json);
}
