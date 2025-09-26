import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "../../../../core/constants/storage_keys.dart" show accessTokenKey, userIdKey, usernameKey;
import "../models/auth_token.dart";

class LocalAuthenticationRepository {
  final FlutterSecureStorage _secureStorage;

  LocalAuthenticationRepository({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> saveToken({required AuthToken authToken}) async {
    await _secureStorage.write(key: accessTokenKey, value: authToken.token);
    await _secureStorage.write(key: userIdKey, value: authToken.id);
    await _secureStorage.write(key: usernameKey, value: authToken.username);
  }

  Future<String?> getAccessToken() {
    return _secureStorage.read(key: accessTokenKey);
  }

  Future<String?> getUserId() {
    return _secureStorage.read(key: userIdKey);
  }

  Future<String?> getUsername() {
    return _secureStorage.read(key: usernameKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: accessTokenKey);
    await _secureStorage.delete(key: userIdKey);
    await _secureStorage.delete(key: usernameKey);
  }
}
