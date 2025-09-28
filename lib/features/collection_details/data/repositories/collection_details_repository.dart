import "package:dio/dio.dart";

import "../../../../core/constants/api_endpoints.dart";
import "../models/collection_details.dart";

class CollectionDetailsRepository {
  final Dio _dio;

  CollectionDetailsRepository({required Dio dio}) : _dio = dio;

  Future<CollectionDetails> getCollectionDetails(String collectionId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>("${ApiEndpoints.collectionsCRUD}/$collectionId");

      if (response.data == null) {
        throw Exception("Failed to fetch collection details: Empty response from server");
      }

      return CollectionDetails.fromJson(response.data!);
    } on DioException catch (e) {
      final errorMessage = "Failed to fetch collection details: ${e.message}\nDio Response: ${e.response?.data}";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to fetch collection details: $e");
    }
  }

  Future<void> deleteCollection(String collectionId) async {
    try {
      await _dio.delete<Map<String, dynamic>>("${ApiEndpoints.collectionsCRUD}/$collectionId");
    } on DioException catch (e) {
      final errorMessage = "Failed to delete collection: ${e.message}\nDio Response: ${e.response?.data}";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to delete collection: $e");
    }
  }
}
