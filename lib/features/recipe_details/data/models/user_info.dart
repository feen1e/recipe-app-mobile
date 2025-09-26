import "package:freezed_annotation/freezed_annotation.dart";

part "user_info.freezed.dart";
part "user_info.g.dart";

@freezed
abstract class UserInfoDto with _$UserInfoDto {
  const factory UserInfoDto({required String username, String? avatarUrl}) = _UserInfoDto;

  factory UserInfoDto.fromJson(Map<String, dynamic> json) => _$UserInfoDtoFromJson(json);
}
