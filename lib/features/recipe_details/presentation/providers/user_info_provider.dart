import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../../core/network/dio_provider.dart";
import "../../data/models/user_info.dart";
import "../../data/repositories/user_info_repository.dart";

part "user_info_provider.g.dart";

@riverpod
UserInfoRepository userInfoRepository(Ref ref) {
  final dio = ref.read(dioProvider);
  return UserInfoRepository(dio);
}

@riverpod
class UserInfo extends _$UserInfo {
  @override
  Future<UserInfoDto> build(String userId) async {
    final repository = ref.read(userInfoRepositoryProvider);
    final userInfo = await repository.getUserInfoById(userId);
    if (userInfo == null) {
      throw Exception("User not found");
    }
    return userInfo;
  }

  Future<void> refresh(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(userInfoRepositoryProvider);
      final userInfo = await repo.getUserInfoById(userId);
      if (userInfo == null) {
        throw Exception("User not found");
      }
      return userInfo;
    });
  }
}
