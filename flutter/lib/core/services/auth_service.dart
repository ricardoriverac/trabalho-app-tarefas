/// Serviço de autenticação simples do aplicativo.
///
/// Este serviço gerencia o estado de autenticação do usuário
/// usando armazenamento local (SharedPreferences).
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

/// Serviço responsável por gerenciar autenticação do usuário.
///
/// Reason: Por ser um MVP/trabalho de faculdade, usamos uma autenticação
/// simplificada sem backend de auth. Em produção, usar Firebase Auth,
/// Auth0 ou similar.
class AuthService {
  /// Repositório de usuários.
  final UserRepository _userRepository;

  /// Chave para armazenar o ID do usuário no SharedPreferences.
  static const String _userIdKey = 'current_user_id';

  /// Chave para armazenar o email do usuário.
  static const String _userEmailKey = 'current_user_email';

  /// Chave para armazenar o nome do usuário.
  static const String _userNameKey = 'current_user_name';

  /// Construtor que recebe o repositório de usuários.
  AuthService({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  /// Verifica se existe um usuário logado.
  ///
  /// Returns:
  ///   true se houver um usuário salvo localmente.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) != null;
  }

  /// Retorna o usuário atual salvo localmente.
  ///
  /// Returns:
  ///   [UserModel] do usuário logado ou null se não houver.
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);

    if (userId == null) return null;

    // Tenta buscar dados atualizados do servidor
    try {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        // Atualiza dados locais
        await _saveUserLocally(user);
        return user;
      }
    } catch (e) {
      // Se falhar, usa dados locais
    }

    // Retorna dados locais como fallback
    return UserModel(
      id: userId,
      name: prefs.getString(_userNameKey),
      email: prefs.getString(_userEmailKey),
    );
  }

  /// Retorna apenas o ID do usuário atual (mais rápido).
  ///
  /// Returns:
  ///   ID do usuário ou null.
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Faz login com email.
  ///
  /// Busca o usuário pelo email no Hasura e salva localmente.
  ///
  /// Args:
  ///   email: Email do usuário.
  ///
  /// Returns:
  ///   [UserModel] do usuário logado.
  ///
  /// Throws:
  ///   Exception se o usuário não for encontrado.
  Future<UserModel> loginWithEmail(String email) async {
    final user = await _userRepository.getUserByEmail(email);

    if (user == null) {
      throw Exception('Usuário não encontrado com este email');
    }

    await _saveUserLocally(user);
    return user;
  }

  /// Faz login com ID do usuário (para testes).
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   [UserModel] do usuário logado.
  Future<UserModel> loginWithId(String userId) async {
    final user = await _userRepository.getUserById(userId);

    if (user == null) {
      throw Exception('Usuário não encontrado');
    }

    await _saveUserLocally(user);
    return user;
  }

  /// Registra um novo usuário.
  ///
  /// Args:
  ///   name: Nome do usuário.
  ///   email: Email do usuário.
  ///
  /// Returns:
  ///   [UserModel] do usuário criado.
  Future<UserModel> register({
    required String name,
    required String email,
  }) async {
    // Verifica se o email já existe
    final existingUser = await _userRepository.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Este email já está cadastrado');
    }

    // Cria novo usuário
    final newUser = UserModel(
      id: '', // Será gerado pelo repositório
      name: name,
      email: email,
    );

    final createdUser = await _userRepository.createUser(newUser);
    await _saveUserLocally(createdUser);

    return createdUser;
  }

  /// Faz logout do usuário atual.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
  }

  /// Salva os dados do usuário localmente.
  Future<void> _saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.id);
    if (user.email != null) {
      await prefs.setString(_userEmailKey, user.email!);
    }
    if (user.name != null) {
      await prefs.setString(_userNameKey, user.name!);
    }
  }
}
