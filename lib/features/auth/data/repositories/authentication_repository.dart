import "local_authentication_repository.dart";
import "remote_authentication_repository.dart";

class AuthenticationRepository {
  final LocalAuthenticationRepository localRepository;
  final RemoteAuthenticationRepository remoteRepository;

  AuthenticationRepository({
    LocalAuthenticationRepository? localRepository,
    RemoteAuthenticationRepository? remoteRepository,
  }) : localRepository = localRepository ?? LocalAuthenticationRepository(),
       remoteRepository = remoteRepository ?? RemoteAuthenticationRepository();

  Future<bool> login({required String identifier, required String password}) async {
    try {
      final authToken = await remoteRepository.login(identifier: identifier, password: password);
      await localRepository.saveToken(authToken: authToken);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register({required String username, required String email, required String password}) async {
    try {
      final authToken = await remoteRepository.register(username: username, email: email, password: password);
      await localRepository.saveToken(authToken: authToken);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await localRepository.clearToken();
  }

  Future<String?> getAccessToken() {
    return localRepository.getAccessToken();
  }

  Future<String?> getUserId() {
    return localRepository.getUserId();
  }

  Future<String?> getUsername() {
    return localRepository.getUsername();
  }
}
