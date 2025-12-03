/// Repositório para operações CRUD de tarefas.
///
/// Este repositório encapsula toda a lógica de comunicação com o Hasura
/// para operações relacionadas a tarefas.
library;

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/graphql_config.dart';
import '../graphql/mutations/task_mutations.dart';
import '../graphql/queries/task_queries.dart';
import '../models/task_model.dart';

/// Repositório responsável por gerenciar operações de tarefas.
///
/// Fornece métodos para criar, ler, atualizar e deletar tarefas,
/// além de operações específicas como marcar como concluída.
class TaskRepository {
  /// Cliente GraphQL para comunicação com o Hasura.
  final GraphQLClient _client;

  /// Gerador de UUIDs para novas tarefas.
  final Uuid _uuid = const Uuid();

  /// Construtor que recebe o cliente GraphQL.
  ///
  /// Se não for fornecido, usa o cliente singleton do [GraphQLConfig].
  TaskRepository({GraphQLClient? client})
      : _client = client ?? GraphQLConfig().client;

  /// Busca todas as tarefas de um usuário.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   Lista de [TaskModel] do usuário.
  ///
  /// Throws:
  ///   Exception se houver erro na comunicação com o servidor.
  Future<List<TaskModel>> getTasks(String userId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getTasksQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar tarefas: ${result.exception.toString()}',
      );
    }

    final tasksData = result.data?['tasks'] as List<dynamic>? ?? [];
    return tasksData
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Busca uma tarefa específica por ID.
  ///
  /// Args:
  ///   taskId: ID da tarefa.
  ///
  /// Returns:
  ///   [TaskModel] se encontrada, null caso contrário.
  Future<TaskModel?> getTaskById(String taskId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getTaskByIdQuery),
        variables: {'id': taskId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar tarefa: ${result.exception.toString()}',
      );
    }

    final taskData = result.data?['tasks_by_pk'];
    if (taskData == null) return null;

    return TaskModel.fromJson(taskData as Map<String, dynamic>);
  }

  /// Busca tarefas pendentes (não concluídas) de um usuário.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   Lista de tarefas pendentes.
  Future<List<TaskModel>> getPendingTasks(String userId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getPendingTasksQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar tarefas pendentes: ${result.exception.toString()}',
      );
    }

    final tasksData = result.data?['tasks'] as List<dynamic>? ?? [];
    return tasksData
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Busca tarefas de hoje.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   Lista de tarefas com data limite para hoje.
  Future<List<TaskModel>> getTodayTasks(String userId) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    final result = await _client.query(
      QueryOptions(
        document: gql(getTodayTasksQuery),
        variables: {
          'userId': userId,
          'today': today,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar tarefas de hoje: ${result.exception.toString()}',
      );
    }

    final tasksData = result.data?['tasks'] as List<dynamic>? ?? [];
    return tasksData
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Busca tarefas atrasadas.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   Lista de tarefas não concluídas com data limite passada.
  Future<List<TaskModel>> getOverdueTasks(String userId) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    final result = await _client.query(
      QueryOptions(
        document: gql(getOverdueTasksQuery),
        variables: {
          'userId': userId,
          'today': today,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar tarefas atrasadas: ${result.exception.toString()}',
      );
    }

    final tasksData = result.data?['tasks'] as List<dynamic>? ?? [];
    return tasksData
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Busca tarefas por categoria.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///   categoryId: ID da categoria.
  ///
  /// Returns:
  ///   Lista de tarefas da categoria especificada.
  Future<List<TaskModel>> getTasksByCategory(
    String userId,
    String categoryId,
  ) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getTasksByCategoryQuery),
        variables: {
          'userId': userId,
          'categoryId': categoryId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar tarefas por categoria: ${result.exception.toString()}',
      );
    }

    final tasksData = result.data?['tasks'] as List<dynamic>? ?? [];
    return tasksData
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Cria uma nova tarefa.
  ///
  /// Args:
  ///   task: Modelo da tarefa a ser criada.
  ///
  /// Returns:
  ///   [TaskModel] da tarefa criada com ID gerado.
  Future<TaskModel> createTask(TaskModel task) async {
    // Gera um novo UUID se não fornecido
    final taskWithId = task.copyWith(
      id: task.id.isEmpty ? _uuid.v4() : task.id,
    );

    final result = await _client.mutate(
      MutationOptions(
        document: gql(createTaskMutation),
        variables: {
          'task': taskWithId.toJson(),
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao criar tarefa: ${result.exception.toString()}',
      );
    }

    final createdTask = result.data?['insert_tasks_one'];
    if (createdTask == null) {
      throw Exception('Erro ao criar tarefa: resposta vazia do servidor');
    }

    return TaskModel.fromJson(createdTask as Map<String, dynamic>);
  }

  /// Atualiza uma tarefa existente.
  ///
  /// Args:
  ///   taskId: ID da tarefa a ser atualizada.
  ///   changes: Map com os campos a serem alterados.
  ///
  /// Returns:
  ///   [TaskModel] da tarefa atualizada.
  Future<TaskModel> updateTask(
    String taskId,
    Map<String, dynamic> changes,
  ) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updateTaskMutation),
        variables: {
          'id': taskId,
          'changes': changes,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao atualizar tarefa: ${result.exception.toString()}',
      );
    }

    final updatedTask = result.data?['update_tasks_by_pk'];
    if (updatedTask == null) {
      throw Exception('Tarefa não encontrada para atualização');
    }

    return TaskModel.fromJson(updatedTask as Map<String, dynamic>);
  }

  /// Deleta uma tarefa.
  ///
  /// Args:
  ///   taskId: ID da tarefa a ser deletada.
  ///
  /// Returns:
  ///   true se a tarefa foi deletada com sucesso.
  Future<bool> deleteTask(String taskId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(deleteTaskMutation),
        variables: {'id': taskId},
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao deletar tarefa: ${result.exception.toString()}',
      );
    }

    return result.data?['delete_tasks_by_pk'] != null;
  }

  /// Alterna o status de conclusão de uma tarefa.
  ///
  /// Args:
  ///   taskId: ID da tarefa.
  ///   completed: Novo status de conclusão.
  ///
  /// Returns:
  ///   true se a operação foi bem-sucedida.
  Future<bool> toggleTaskCompletion(String taskId, bool completed) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(toggleTaskCompletionMutation),
        variables: {
          'id': taskId,
          'completed': completed,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao atualizar status da tarefa: ${result.exception.toString()}',
      );
    }

    return result.data?['update_tasks_by_pk'] != null;
  }

  /// Atualiza a prioridade de uma tarefa.
  ///
  /// Args:
  ///   taskId: ID da tarefa.
  ///   priority: Nova prioridade (low, medium, high).
  ///
  /// Returns:
  ///   true se a operação foi bem-sucedida.
  Future<bool> updateTaskPriority(String taskId, String priority) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updateTaskPriorityMutation),
        variables: {
          'id': taskId,
          'priority': priority,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao atualizar prioridade: ${result.exception.toString()}',
      );
    }

    return result.data?['update_tasks_by_pk'] != null;
  }

  /// Busca contadores de tarefas.
  ///
  /// Args:
  ///   userId: ID do usuário.
  ///
  /// Returns:
  ///   Map com contadores (total, pending, completed, overdue, today).
  Future<Map<String, int>> getTaskCounts(String userId) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    final result = await _client.query(
      QueryOptions(
        document: gql(getTaskCountsQuery),
        variables: {
          'userId': userId,
          'today': today,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(
        'Erro ao buscar contadores: ${result.exception.toString()}',
      );
    }

    return {
      'total': result.data?['total']?['aggregate']?['count'] as int? ?? 0,
      'pending': result.data?['pending']?['aggregate']?['count'] as int? ?? 0,
      'completed':
          result.data?['completed']?['aggregate']?['count'] as int? ?? 0,
      'overdue': result.data?['overdue']?['aggregate']?['count'] as int? ?? 0,
      'today': result.data?['today']?['aggregate']?['count'] as int? ?? 0,
    };
  }
}

