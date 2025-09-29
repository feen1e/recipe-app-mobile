import "dart:io";
import "package:dio/dio.dart";
import "package:form_builder_image_picker/form_builder_image_picker.dart";
import "package:logging/logging.dart";
import "package:path_provider/path_provider.dart";

import "../../../../core/constants/api_endpoints.dart";
import "../models/create_recipe.dart";

class CreateOrUpdateRecipeRepository {
  final Dio _dio;
  static final _logger = Logger("CreateOrUpdateRecipeRepository");

  CreateOrUpdateRecipeRepository({required Dio dio}) : _dio = dio;

  Future<String> addPhoto(XFile imageFile, String type) async {
    try {
      _logger.info("Uploading image of type: $type, file: ${imageFile.name}");

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: imageFile.name),
      });

      final response = await _dio.post<Map<String, dynamic>>("${ApiEndpoints.imageUpload}/$type", data: formData);

      _logger.info("Image upload response: ${response.data}");

      if (response.data != null && response.data!["url"] != null) {
        return response.data!["url"] as String;
      } else {
        throw Exception("Failed to upload image: No URL in response");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to upload image";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to upload image ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to upload image: ${e.message}";
      } else {
        errorMessage = "Failed to upload image: Network error - ${e.type}";
      }

      _logger.severe(errorMessage);
      throw Exception(errorMessage);
    } on Exception catch (e) {
      final errorMessage = "Failed to upload image: Unexpected error - $e";
      _logger.severe(errorMessage);
      throw Exception(errorMessage);
    }
  }

  Future<XFile?> getPhotoFromUrl(String imageUrl) async {
    try {
      _logger.info("Fetching image from URL: $imageUrl");

      final response = await _dio.get<List<int>>(imageUrl, options: Options(responseType: ResponseType.bytes));

      if (response.data == null) {
        throw Exception("Failed to download image: Empty response");
      }

      final tempDir = await getTemporaryDirectory();

      final uri = Uri.parse(imageUrl);
      String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : "downloaded_image.jpg";

      if (!fileName.contains(".")) {
        fileName += ".jpg";
      }

      final tempFile = File("${tempDir.path}/$fileName");
      await tempFile.writeAsBytes(response.data!);

      _logger.info("Image downloaded and saved to: ${tempFile.path}");

      return XFile(tempFile.path);
    } on DioException catch (e) {
      var errorMessage = "Failed to download image from URL";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        errorMessage = "Failed to download image ($statusCode): ${e.response!.statusMessage ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to download image: ${e.message}";
      } else {
        errorMessage = "Failed to download image: Network error - ${e.type}";
      }

      _logger.severe(errorMessage);
      return null;
    } on Exception catch (e) {
      final errorMessage = "Failed to download image: Unexpected error - $e";
      _logger.severe(errorMessage);
      return null;
    }
  }

  Future<RecipeResponse> createRecipe(CreateRecipeRequest request) async {
    try {
      _logger.info("Creating recipe with data: ${request.toJson()}");

      final response = await _dio.post<Map<String, dynamic>>(ApiEndpoints.recipesCRUD, data: request.toJson());

      _logger.info("Create recipe response: ${response.data}");

      if (response.data != null) {
        return RecipeResponse.fromJson(response.data!);
      } else {
        throw Exception("Failed to create recipe: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to create recipe";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to create recipe ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to create recipe: ${e.message}";
      } else {
        errorMessage = "Failed to create recipe: Network error - ${e.type}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to create recipe: Unexpected error - $e");
    }
  }

  Future<RecipeResponse> updateRecipe(String id, UpdateRecipeRequest request) async {
    try {
      _logger.info("Updating recipe $id with data: ${request.toJson()}");

      final response = await _dio.patch<Map<String, dynamic>>(
        "${ApiEndpoints.recipesCRUD}/$id",
        data: request.toJson(),
      );

      _logger.info("Update recipe response: ${response.data}");

      if (response.data != null) {
        return RecipeResponse.fromJson(response.data!);
      } else {
        throw Exception("Failed to update recipe: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to update recipe";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to update recipe ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to update recipe: ${e.message}";
      } else {
        errorMessage = "Failed to update recipe: Network error - ${e.type}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to update recipe: Unexpected error - $e");
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      _logger.info("Deleting recipe $id");

      await _dio.delete<void>("${ApiEndpoints.recipesCRUD}/$id");

      _logger.info("Recipe $id deleted successfully");
    } on DioException catch (e) {
      var errorMessage = "Failed to delete recipe";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to delete recipe ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to delete recipe: ${e.message}";
      } else {
        errorMessage = "Failed to delete recipe: Network error - ${e.type}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to delete recipe: Unexpected error - $e");
    }
  }

  Future<RecipeResponse> getRecipe(String id) async {
    try {
      _logger.info("Fetching recipe $id");

      final response = await _dio.get<Map<String, dynamic>>("${ApiEndpoints.recipesCRUD}/$id");

      _logger.info("Get recipe response: ${response.data}");

      if (response.data != null) {
        return RecipeResponse.fromJson(response.data!);
      } else {
        throw Exception("Failed to get recipe: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to get recipe";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to get recipe ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to get recipe: ${e.message}";
      } else {
        errorMessage = "Failed to get recipe: Network error - ${e.type}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to get recipe: Unexpected error - $e");
    }
  }
}
