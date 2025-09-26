import "package:freezed_annotation/freezed_annotation.dart";

part "auth_token.freezed.dart";
part "auth_token.g.dart";

@freezed
abstract class AuthToken with _$AuthToken {
  const factory AuthToken({required String token, required String id, required String username}) = _AuthToken;

  factory AuthToken.fromJson(Map<String, dynamic> json) => _$AuthTokenFromJson(json);
}
