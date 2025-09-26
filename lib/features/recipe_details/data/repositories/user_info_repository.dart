import "package:dio/dio.dart";

import "../../../../core/constants/api_endpoints.dart";
import "../models/user_info.dart";

class UserInfoRepository {
  final Dio _dio;

  UserInfoRepository(this._dio);

  Future<UserInfoDto?> getUserInfoById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>("${ApiEndpoints.userInfo}/$id");
    return response.data != null ? UserInfoDto.fromJson(response.data!) : null;
  }
}
