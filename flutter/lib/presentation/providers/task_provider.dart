/// Provider de tarefas usando Riverpod.
///
/// Este arquivo gerencia o estado das tarefas em toda a aplicação,
/// incluindo filtros, ordenação e operações CRUD.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'auth_provider.dart';

// ============================================
// ENUMS E TIPOS DE FILTRO
// ============================================

/// Tipos de filtro de status.
enum TaskStatusFilter {
  /// Todas as tarefas.
  all,

  /// Apenas tarefas pendentes.
  pending,

  /// Apenas tarefas concluídas.
  completed,

  /// Apenas tarefas de hoje.
  today,

  /// Apenas tarefas atrasadas.
  overdue,
}

/// Tipos de ordenação.
enum TaskSortOrder {
  /// Por prioridade (alta primeiro).
  priority,

  /// Por data limite (mais próxima primeiro).
  dueDate,

  /// Por data de criação (mais recente primeiro).
  createdAt,

  /// Alfabética por título.
  title,
}

// ============================================
// ESTADO DAS TAREFAS
// ============================================

/// Estado completo das tarefas.
class TasksState {
  /// Lista de todas as tarefas.
  final List<TaskModel> tasks;

  /// Indica se está carregando.
  final bool isLoading;

  /// Mensagem de erro, se houver.
  final String? errorMessage;

  /// Filtro de status atual.
  final TaskStatusFilter statusFilter;

  /// Filtro de prioridade atual (null = todas).
  final String? priorityFilter;

  /// Filtro de categoria atual (null = todas).
  final String? categoryFilter;

  /// Ordenação atual.
  final TaskSortOrder sortOrder;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter = TaskStatusFilter.all,
    this.priorityFilter,
    this.categoryFilter,
    this.sortOrder = TaskSortOrder.priority,
  });

  /// Retorna as tarefas filtradas e ordenadas.
  List<TaskModel> get filteredTasks {
    var result = List<TaskModel>.from(tasks);

    // Aplica filtro de status
    switch (statusFilter) {
      case TaskStatusFilter.pending:
        result = result.where((t) => !t.completed).toList();
        break;
      case TaskStatusFilter.completed:
        result = result.where((t) => t.completed).toList();
        break;
      case TaskStatusFilter.today:
        result = result.where((t) => t.isDueToday).toList();
        break;
      case TaskStatusFilter.overdue:
        result = result.where((t) => t.isOverdue).toList();
        break;
      case TaskStatusFilter.all:
        break;
    }

    // Aplica filtro de prioridade
    if (priorityFilter != null) {
      result = result.where((t) => t.priority == priorityFilter).toList();
    }

    // Aplica filtro de categoria
    if (categoryFilter != null) {
      result = result.where((t) => t.categoryId == categoryFilter).toList();
    }

    // Aplica ordenação
    switch (sortOrder) {
      case TaskSortOrder.priority:
        result.sort((a, b) {
          // Não concluídas primeiro, depois por prioridade
          if (a.completed != b.completed) {
            return a.completed ? 1 : -1;
          }
          return b.priorityWeight.compareTo(a.priorityWeight);
        });
        break;
      case TaskSortOrder.dueDate:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSortOrder.createdAt:
        result.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
      case TaskSortOrder.title:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return result;
  }

  /// Contadores de tarefas.
  Map<String, int> get counts => {
    'total': tasks.length,
    'pending': tasks.where((t) => !t.completed).length,
    'completed': tasks.where((t) => t.completed).length,
    'today': tasks.where((t) => t.isDueToday).length,
    'overdue': tasks.where((t) => t.isOverdue).length,
    'highPriority': tasks
        .where((t) => t.priority == TaskPriority.high && !t.completed)
        .length,
  };

  /// Cria uma cópia com campos alterados.
  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
    TaskStatusFilter? statusFilter,
    String? priorityFilter,
    String? categoryFilter,
    TaskSortOrder? sortOrder,
    bool clearError = false,
    bool clearPriorityFilter = false,
    bool clearCategoryFilter = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: clearPriorityFilter
          ? null
          : (priorityFilter ?? this.priorityFilter),
      categoryFilter: clearCategoryFilter
          ? null
          : (categoryFilter ?? this.categoryFilter),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// ============================================
// NOTIFIER DE TAREFAS
// ============================================

/// Notifier responsável por gerenciar o estado das tarefas.
class TasksNotifier extends StateNotifier<TasksState> {
  /// Repositório de tarefas.
  final TaskRepository _taskRepository;

  /// ID do usuário atual.
  final String? _userId;

  /// Construtor.
  TasksNotifier(this._taskRepository, this._userId) : super(const TasksState());

  /// Carrega as tarefas do usuário.
  Future<void> loadTasks() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final tasks = await _taskRepository.getTasks(_userId);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar tarefas: ${e.toString()}',
      );
    }
  }

  /// Cria uma nova tarefa.
  Future<bool> createTask(TaskModel task) async {
    try {
      await _taskRepository.createTask(task);
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao criar tarefa: ${e.toString()}',
      );
      return false;
    }
  }

  /// Atualiza uma tarefa.
  Future<bool> updateTask(String taskId, Map<String, dynamic> changes) async {
    try {
      await _taskRepository.updateTask(taskId, changes);
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar tarefa: ${e.toString()}',
      );
      return false;
    }
  }

  /// Deleta uma tarefa.
  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao deletar tarefa: ${e.toString()}',
      );
      return false;
    }
  }

  /// Alterna o status de conclusão de uma tarefa.
  Future<bool> toggleTaskCompletion(String taskId, bool completed) async {
    try {
      await _taskRepository.toggleTaskCompletion(taskId, completed);
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar tarefa: ${e.toString()}',
      );
      return false;
    }
  }

  /// Define o filtro de status.
  void setStatusFilter(TaskStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
  }

  /// Define o filtro de prioridade.
  void setPriorityFilter(String? priority) {
    if (priority == null) {
      state = state.copyWith(clearPriorityFilter: true);
    } else {
      state = state.copyWith(priorityFilter: priority);
    }
  }

  /// Define o filtro de categoria.
  void setCategoryFilter(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategoryFilter: true);
    } else {
      state = state.copyWith(categoryFilter: categoryId);
    }
  }

  /// Define a ordenação.
  void setSortOrder(TaskSortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  /// Limpa todos os filtros.
  void clearFilters() {
    state = state.copyWith(
      statusFilter: TaskStatusFilter.all,
      clearPriorityFilter: true,
      clearCategoryFilter: true,
    );
  }

  /// Limpa a mensagem de erro.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ============================================
// PROVIDERS
// ============================================

/// Provider do repositório de tarefas.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

/// Provider do estado de tarefas.
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return TasksNotifier(repository, userId);
});

/// Provider das tarefas filtradas.
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final state = ref.watch(tasksProvider);
  return state.filteredTasks;
});

/// Provider dos contadores de tarefas.
final taskCountsProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(tasksProvider);
  return state.counts;
});
