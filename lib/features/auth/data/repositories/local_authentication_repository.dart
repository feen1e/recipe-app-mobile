import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "../../../../core/constants/storage_keys.dart" show accessTokenKey;
import "../models/auth_token.dart";

class LocalAuthenticationRepository {
  final FlutterSecureStorage _secureStorage;

  LocalAuthenticationRepository({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> saveToken({required AuthToken authToken}) async {
    await _secureStorage.write(key: accessTokenKey, value: authToken.token);
  }

  Future<String?> getAccessToken() {
    return _secureStorage.read(key: accessTokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: accessTokenKey);
  }
}
