import "package:freezed_annotation/freezed_annotation.dart";

import "../../../recipe_details/data/models/recipe.dart";

part "collection_details.freezed.dart";
part "collection_details.g.dart";

@freezed
abstract class CollectionDetails with _$CollectionDetails {
  const factory CollectionDetails({
    required String id,
    required String name,
    String? description,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<RecipeDetailsDto> recipes,
  }) = _CollectionDetails;

  factory CollectionDetails.fromJson(Map<String, dynamic> json) => _$CollectionDetailsFromJson(json);
}
