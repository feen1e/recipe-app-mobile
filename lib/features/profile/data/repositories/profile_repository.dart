import "dart:developer";

import "package:dio/dio.dart";
import "../../../../core/constants/api_endpoints.dart";
import "../models/profile.dart";

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({required Dio dio}) : _dio = dio;

  Future<Profile> getUserProfile(String username) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>("${ApiEndpoints.userProfile}/$username");

      if (response.data != null) {
        return Profile.fromJson(response.data!);
      } else {
        throw Exception("Failed to fetch user profile: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to fetch user profile";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to fetch user profile ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to fetch user profile: ${e.message}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to fetch user profile: $e");
    }
  }

  Future<List<Recipe>> getUserRecipes(String username) async {
    try {
      final response = await _dio.get<List<dynamic>>("${ApiEndpoints.userRecipes}$username");

      if (response.data != null) {
        final recipesJson = response.data!;
        return recipesJson.map((json) => Recipe.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to fetch user recipes";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to fetch user recipes ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to fetch user recipes: ${e.message}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to fetch user recipes: $e");
    }
  }

  Future<List<Rating>> getUserRatings(String username) async {
    try {
      log("Fetching ratings for username: $username");
      log("Endpoint: ${ApiEndpoints.userRatings}/$username");

      final response = await _dio.get<List<dynamic>>("${ApiEndpoints.userRatings}/$username");

      log("User ratings response status: ${response.statusCode}");
      log("User ratings response data: ${response.data}");

      if (response.data != null) {
        final ratingsJson = response.data!;
        return ratingsJson.map((json) => Rating.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      log("DioException type: ${e.type}");
      log("DioException message: ${e.message}");
      log("DioException response: ${e.response?.data}");

      if (e.response != null) {
        final statusCode = e.response!.statusCode;

        if (statusCode == 404) {
          log("Ratings endpoint not found (404) - returning empty list");
          return [];
        }

        final responseData = e.response!.data;
        final errorMessage =
            "Failed to fetch user ratings ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
        throw Exception(errorMessage);
      } else if (e.message != null) {
        throw Exception("Failed to fetch user ratings: ${e.message}");
      }

      throw Exception("Failed to fetch user ratings: Unknown DioException");
    } on Exception catch (e) {
      log("Unexpected error fetching user ratings: $e");
      return [];
    }
  }

  Future<Profile> updateProfile({String? username, String? bio, String? avatarUrl}) async {
    try {
      final body = <String, dynamic>{"username": ?username, "bio": ?bio, "avatarUrl": ?avatarUrl};

      final response = await _dio.patch<Map<String, dynamic>>(ApiEndpoints.userProfile, data: body);

      if (response.data != null) {
        return Profile.fromJson(response.data!);
      } else {
        throw Exception("Failed to update profile: Empty response from server");
      }
    } on DioException catch (e) {
      var errorMessage = "Failed to update profile";
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        errorMessage = "Failed to update profile ($statusCode): ${responseData?.toString() ?? 'Unknown error'}";
      } else if (e.message != null) {
        errorMessage = "Failed to update profile: ${e.message}";
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }
}
