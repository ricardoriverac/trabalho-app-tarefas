/// Repositório para operações CRUD de usuários.
///
/// Este repositório encapsula toda a lógica de comunicação com o Hasura
/// para operações relacionadas a usuários.
library;

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/graphql_config.dart';
import '../graphql/mutations/user_mutations.dart';
import '../graphql/queries/user_queries.dart';
import '../models/user_model.dart';

/// Repositório responsável por gerenciar operações de usuários.
///
/// Fornece métodos para criar, buscar e atualizar usuários,
/// além de operações para estatísticas de produtividade.
class UserRepository {
  /// Cliente GraphQL para comunicação com o Hasura.
  final GraphQLClient _client;

  /// Gerador de UUIDs para novos usuários.
  final Uuid _uuid = const Uuid();

  /// Construtor que recebe o cliente GraphQL.
  ///
  /// Se não for fornecido, usa o cliente singleton do [GraphQLConfig].
  UserRepository({GraphQLClient? client})
      : _client = client ?? GraphQLConfig().client;

  /// Busca um usuário por ID.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   [UserModel] se encontrado, null caso contrário.
  Future<UserModel?> getUserById(String userId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getUserByIdQuery),
        variables: {'id': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar usuário: ${result.exception.toString()}',
      );
    }

    final userData = result.data?['users_by_pk'];
    if (userData == null) return null;

    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

  /// Busca um usuário por email.
  ///
  /// Args:
  ///   email: Email do usuário.
  ///
  /// Returns:
  ///   [UserModel] se encontrado, null caso contrário.
  Future<UserModel?> getUserByEmail(String email) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getUserByEmailQuery),
        variables: {'email': email},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar usuário por email: ${result.exception.toString()}',
      );
    }

    final usersData = result.data?['users'] as List<dynamic>? ?? [];
    if (usersData.isEmpty) return null;

    return UserModel.fromJson(usersData.first as Map<String, dynamic>);
  }

  /// Cria um novo usuário.
  ///
  /// Args:
  ///   user: Modelo do usuário a ser criado.
  ///
  /// Returns:
  ///   [UserModel] do usuário criado com ID gerado.
  Future<UserModel> createUser(UserModel user) async {
    // Gera um novo UUID se não fornecido
    final userWithId = user.copyWith(
      id: user.id.isEmpty ? _uuid.v4() : user.id,
    );

    final result = await _client.mutate(
      MutationOptions(
        document: gql(createUserMutation),
        variables: {
          'user': userWithId.toJson(),
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao criar usuário: ${result.exception.toString()}',
      );
    }

    final createdUser = result.data?['insert_users_one'];
    if (createdUser == null) {
      throw Exception('Erro ao criar usuário: resposta vazia do servidor');
    }

    return UserModel.fromJson(createdUser as Map<String, dynamic>);
  }

  /// Cria ou atualiza um usuário (upsert por email).
  ///
  /// Reason: Útil para cenários de login onde queremos criar
  /// o usuário se não existir, ou atualizar se já existir.
  ///
  /// Args:
  ///   user: Modelo do usuário.
  ///
  /// Returns:
  ///   [UserModel] do usuário criado ou atualizado.
  Future<UserModel> upsertUser(UserModel user) async {
    final userWithId = user.copyWith(
      id: user.id.isEmpty ? _uuid.v4() : user.id,
    );

    final result = await _client.mutate(
      MutationOptions(
        document: gql(upsertUserMutation),
        variables: {
          'user': userWithId.toJson(),
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao criar/atualizar usuário: ${result.exception.toString()}',
      );
    }

    final upsertedUser = result.data?['insert_users_one'];
    if (upsertedUser == null) {
      throw Exception('Erro ao criar/atualizar usuário');
    }

    return UserModel.fromJson(upsertedUser as Map<String, dynamic>);
  }

  /// Atualiza um usuário existente.
  ///
  /// Args:
  ///   userId: ID do usuário a ser atualizado.
  ///   changes: Map com os campos a serem alterados.
  ///
  /// Returns:
  ///   [UserModel] do usuário atualizado.
  Future<UserModel> updateUser(
    String userId,
    Map<String, dynamic> changes,
  ) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updateUserMutation),
        variables: {
          'id': userId,
          'changes': changes,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao atualizar usuário: ${result.exception.toString()}',
      );
    }

    final updatedUser = result.data?['update_users_by_pk'];
    if (updatedUser == null) {
      throw Exception('Usuário não encontrado para atualização');
    }

    return UserModel.fromJson(updatedUser as Map<String, dynamic>);
  }

  /// Busca estatísticas do usuário.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   Map com estatísticas do usuário.
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final now = DateTime.now();
    // Calcula o início da semana (segunda-feira)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final result = await _client.query(
      QueryOptions(
        document: gql(getUserStatsQuery),
        variables: {
          'userId': userId,
          'weekStart': weekStart.toIso8601String(),
          'weekEnd': weekEnd.toIso8601String(),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar estatísticas: ${result.exception.toString()}',
      );
    }

    final data = result.data;
    if (data == null) {
      throw Exception('Erro ao buscar estatísticas: resposta vazia');
    }

    return {
      'user': data['user'] != null
          ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
          : null,
      'totalTasks':
          data['total_tasks']?['aggregate']?['count'] as int? ?? 0,
      'completedTasks':
          data['completed_tasks']?['aggregate']?['count'] as int? ?? 0,
      'weekCompleted':
          data['week_completed']?['aggregate']?['count'] as int? ?? 0,
      'avgDuration':
          data['week_completed']?['aggregate']?['avg']?['duration_minutes']
              as double? ??
          0.0,
      'avgProductivity':
          data['week_completed']?['aggregate']?['avg']?['productivity_score']
              as double? ??
          0.0,
      'categoriesCount':
          data['categories_count']?['aggregate']?['count'] as int? ?? 0,
    };
  }
}

