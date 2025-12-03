/// Repositório para operações CRUD de categorias.
///
/// Este repositório encapsula toda a lógica de comunicação com o Hasura
/// para operações relacionadas a categorias.
library;

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/graphql_config.dart';
import '../graphql/mutations/category_mutations.dart';
import '../graphql/queries/category_queries.dart';
import '../models/category_model.dart';

/// Repositório responsável por gerenciar operações de categorias.
///
/// Categorias são usadas para agrupar tarefas por projeto ou área
/// (ex: Trabalho, Casa, Estudos).
class CategoryRepository {
  /// Cliente GraphQL para comunicação com o Hasura.
  final GraphQLClient _client;

  /// Gerador de UUIDs para novas categorias.
  final Uuid _uuid = const Uuid();

  /// Construtor que recebe o cliente GraphQL.
  ///
  /// Se não for fornecido, usa o cliente singleton do [GraphQLConfig].
  CategoryRepository({GraphQLClient? client})
      : _client = client ?? GraphQLConfig().client;

  /// Busca todas as categorias de um usuário.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   Lista de [CategoryModel] do usuário ordenadas por nome.
  Future<List<CategoryModel>> getCategories(String userId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getCategoriesQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar categorias: ${result.exception.toString()}',
      );
    }

    final categoriesData =
        result.data?['categories'] as List<dynamic>? ?? [];
    return categoriesData
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Busca uma categoria específica por ID.
  ///
  /// Args:
  ///   categoryId: ID da categoria.
  ///
  /// Returns:
  ///   [CategoryModel] se encontrada, null caso contrário.
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getCategoryByIdQuery),
        variables: {'id': categoryId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar categoria: ${result.exception.toString()}',
      );
    }

    final categoryData = result.data?['categories_by_pk'];
    if (categoryData == null) return null;

    return CategoryModel.fromJson(categoryData as Map<String, dynamic>);
  }

  /// Busca categorias com contagem de tarefas.
  ///
  /// Reason: Útil para exibir no menu lateral quantas tarefas
  /// cada categoria possui.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   Lista de categorias com dados agregados de tarefas.
  Future<List<Map<String, dynamic>>> getCategoriesWithTaskCount(
    String userId,
  ) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getCategoriesWithTaskCountQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar categorias com contagem: ${result.exception.toString()}',
      );
    }

    final categoriesData =
        result.data?['categories'] as List<dynamic>? ?? [];

    return categoriesData.map((json) {
      final category = CategoryModel.fromJson(json as Map<String, dynamic>);
      final totalTasks =
          json['tasks_aggregate']?['aggregate']?['count'] as int? ?? 0;
      final pendingTasks =
          json['pending_tasks']?['aggregate']?['count'] as int? ?? 0;

      return {
        'category': category,
        'totalTasks': totalTasks,
        'pendingTasks': pendingTasks,
      };
    }).toList();
  }

  /// Cria uma nova categoria.
  ///
  /// Args:
  ///   category: Modelo da categoria a ser criada.
  ///
  /// Returns:
  ///   [CategoryModel] da categoria criada com ID gerado.
  Future<CategoryModel> createCategory(CategoryModel category) async {
    // Gera um novo UUID se não fornecido
    final categoryWithId = category.copyWith(
      id: category.id.isEmpty ? _uuid.v4() : category.id,
    );

    final result = await _client.mutate(
      MutationOptions(
        document: gql(createCategoryMutation),
        variables: {
          'category': categoryWithId.toJson(),
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao criar categoria: ${result.exception.toString()}',
      );
    }

    final createdCategory = result.data?['insert_categories_one'];
    if (createdCategory == null) {
      throw Exception('Erro ao criar categoria: resposta vazia do servidor');
    }

    return CategoryModel.fromJson(createdCategory as Map<String, dynamic>);
  }

  /// Atualiza uma categoria existente.
  ///
  /// Args:
  ///   categoryId: ID da categoria a ser atualizada.
  ///   changes: Map com os campos a serem alterados.
  ///
  /// Returns:
  ///   [CategoryModel] da categoria atualizada.
  Future<CategoryModel> updateCategory(
    String categoryId,
    Map<String, dynamic> changes,
  ) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updateCategoryMutation),
        variables: {
          'id': categoryId,
          'changes': changes,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao atualizar categoria: ${result.exception.toString()}',
      );
    }

    final updatedCategory = result.data?['update_categories_by_pk'];
    if (updatedCategory == null) {
      throw Exception('Categoria não encontrada para atualização');
    }

    return CategoryModel.fromJson(updatedCategory as Map<String, dynamic>);
  }

  /// Deleta uma categoria.
  ///
  /// Reason: Ao deletar uma categoria, as tarefas associadas
  /// terão category_id definido como NULL (não serão deletadas).
  ///
  /// Args:
  ///   categoryId: ID da categoria a ser deletada.
  ///
  /// Returns:
  ///   true se a categoria foi deletada com sucesso.
  Future<bool> deleteCategory(String categoryId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(deleteCategoryMutation),
        variables: {'id': categoryId},
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao deletar categoria: ${result.exception.toString()}',
      );
    }

    return result.data?['delete_categories_by_pk'] != null;
  }
}

