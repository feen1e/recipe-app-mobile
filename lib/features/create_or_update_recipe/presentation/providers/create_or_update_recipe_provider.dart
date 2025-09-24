import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:form_builder_image_picker/form_builder_image_picker.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../../core/network/dio_provider.dart";
import "../../data/repositories/create_or_update_recipe_repository.dart";

part "create_or_update_recipe_provider.g.dart";

@riverpod
CreateOrUpdateRecipeRepository repository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CreateOrUpdateRecipeRepository(dio: dio);
}

@riverpod
Future<XFile?> photo(Ref ref, String url) {
  final repo = ref.read(repositoryProvider);
  return repo.getPhotoFromUrl(url);
}
