/// Provider de autenticação usando Riverpod.
///
/// Este arquivo gerencia o estado de autenticação em toda a aplicação.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';

/// Estado de autenticação do aplicativo.
sealed class AuthState {
  const AuthState();
}

/// Estado inicial - verificando se há usuário logado.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carregamento.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Usuário autenticado.
class AuthAuthenticated extends AuthState {
  /// Usuário logado.
  final UserModel user;

  const AuthAuthenticated(this.user);
}

/// Usuário não autenticado.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Erro de autenticação.
class AuthError extends AuthState {
  /// Mensagem de erro.
  final String message;

  const AuthError(this.message);
}

/// Notifier responsável por gerenciar o estado de autenticação.
class AuthNotifier extends StateNotifier<AuthState> {
  /// Serviço de autenticação.
  final AuthService _authService;

  /// Construtor que inicializa o estado e verifica autenticação.
  AuthNotifier(this._authService) : super(const AuthInitial()) {
    checkAuthStatus();
  }

  /// Verifica se há um usuário logado.
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  /// Faz login com email.
  Future<void> loginWithEmail(String email) async {
    state = const AuthLoading();

    try {
      final user = await _authService.loginWithEmail(email);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Faz login com ID (para desenvolvimento/testes).
  Future<void> loginWithId(String userId) async {
    state = const AuthLoading();

    try {
      final user = await _authService.loginWithId(userId);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Registra um novo usuário.
  Future<void> register({required String name, required String email}) async {
    state = const AuthLoading();

    try {
      final user = await _authService.register(name: name, email: email);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Faz logout.
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthUnauthenticated();
  }

  /// Retorna o ID do usuário atual ou null.
  String? get currentUserId {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user.id;
    }
    return null;
  }
}

/// Provider do serviço de autenticação.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider do estado de autenticação.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Provider que retorna apenas o ID do usuário atual.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.user.id;
  }
  return null;
});

/// Provider que retorna o usuário atual.
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});
