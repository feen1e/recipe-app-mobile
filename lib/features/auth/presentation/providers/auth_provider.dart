import "dart:async";

import "package:flutter/widgets.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../../core/network/dio_provider.dart";
import "../../data/models/auth_state.dart";
import "../../data/repositories/authentication_repository.dart";
import "../../data/repositories/local_authentication_repository.dart";
import "../../data/repositories/remote_authentication_repository.dart";

part "auth_provider.g.dart";

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final AuthenticationRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.read(authenticationRepositoryProvider);
    unawaited(checkLoginStatus());
    return const AuthState.initial();
  }

  Future<void> checkLoginStatus() async {
    state = const AuthState.loading();
    final accessToken = await _authRepository.getAccessToken();
    if (accessToken != null) {
      state = const AuthState.authenticated();
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String identifier, String password) async {
    state = const AuthState.loading();
    try {
      await _authRepository.login(identifier: identifier, password: password);
      state = const AuthState.authenticated();
    } on Exception catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = const AuthState.loading();
    try {
      await _authRepository.register(username: username, email: email, password: password);
      state = const AuthState.authenticated();
    } on Exception catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }
}

@riverpod
AuthenticationRepository authenticationRepository(Ref ref) {
  final dioInstance = ref.read(dioProvider);
  return AuthenticationRepository(
    localRepository: LocalAuthenticationRepository(),
    remoteRepository: RemoteAuthenticationRepository(dio: dioInstance),
  );
}

class AuthNotifierListener extends ChangeNotifier {
  AuthNotifierListener(this.ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }

  final WidgetRef ref;
}
