import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../../core/network/dio_provider.dart";
import "../../data/models/collection_details.dart";
import "../../data/repositories/collection_details_repository.dart";

part "collection_details_provider.g.dart";

@riverpod
CollectionDetailsRepository collectionDetailsRepository(Ref ref) {
  final dio = ref.read(dioProvider);
  return CollectionDetailsRepository(dio: dio);
}

@riverpod
Future<CollectionDetails> collectionDetails(Ref ref, String collectionId) {
  final repository = ref.read(collectionDetailsRepositoryProvider);
  return repository.getCollectionDetails(collectionId);
}
