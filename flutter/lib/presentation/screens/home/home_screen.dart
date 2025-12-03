/// Tela principal do aplicativo Smart Task List.
///
/// Esta tela exibe a lista de tarefas com filtros, ordenação
/// e permite navegação para criação e edição de tarefas.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/task_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/daily_summary.dart';
import '../../widgets/task_card.dart';
import '../../widgets/filter_bar.dart';
import '../agenda/agenda_screen.dart';
import '../task/task_form_screen.dart';

/// Tela inicial com lista de tarefas.
///
/// Exibe tarefas do usuário organizadas por status e prioridade,
/// com opções de filtro, ordenação e criação de novas tarefas.
class HomeScreen extends ConsumerStatefulWidget {
  /// Construtor padrão.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega tarefas e categorias ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksProvider.notifier).loadTasks();
      ref.read(categoriesProvider.notifier).loadCategories();
    });
  }

  /// Alterna o status de conclusão de uma tarefa.
  Future<void> _toggleTaskCompletion(TaskModel task) async {
    final success = await ref
        .read(tasksProvider.notifier)
        .toggleTaskCompletion(task.id, !task.completed);

    if (!success && mounted) {
      _showErrorSnackBar('Erro ao atualizar tarefa');
    }
  }

  /// Deleta uma tarefa.
  Future<void> _deleteTask(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tarefa'),
        content: Text('Deseja excluir "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(tasksProvider.notifier)
          .deleteTask(task.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarefa excluída com sucesso'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          _showErrorSnackBar('Erro ao excluir tarefa');
        }
      }
    }
  }

  /// Navega para a tela de criação/edição de tarefa.
  Future<void> _navigateToTaskForm({TaskModel? task}) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task, userId: userId),
      ),
    );

    if (result == true) {
      ref.read(tasksProvider.notifier).loadTasks();
    }
  }

  /// Mostra menu de opções.
  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Atualizar'),
              onTap: () {
                Navigator.pop(context);
                ref.read(tasksProvider.notifier).loadTasks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_list_off),
              title: const Text('Limpar filtros'),
              onTap: () {
                Navigator.pop(context);
                ref.read(tasksProvider.notifier).clearFilters();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra snackbar de erro.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final counts = ref.watch(taskCountsProvider);
    final user = ref.watch(currentUserProvider);

    // Mostra erros
    ref.listen<TasksState>(tasksProvider, (previous, next) {
      if (next.errorMessage != null && previous?.errorMessage == null) {
        _showErrorSnackBar(next.errorMessage!);
        ref.read(tasksProvider.notifier).clearError();
      }
    });

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Minhas Tarefas'),
            if (user != null)
              Text(
                'Olá, ${user.name ?? 'Usuário'}!',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          // Contador de tarefas pendentes
          if (counts['pending']! > 0)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${counts['pending']} pendentes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumo do dia (clicável para ir à agenda)
          CompactDailySummary(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AgendaScreen()),
            ),
          ),

          // Barra de filtros
          const FilterBar(),

          // Lista de tarefas
          Expanded(child: _buildBody(tasksState, filteredTasks)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToTaskForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa'),
      ),
    );
  }

  /// Constrói o corpo da tela baseado no estado atual.
  Widget _buildBody(TasksState state, List<TaskModel> tasks) {
    if (state.isLoading && state.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(tasksProvider.notifier).loadTasks(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (tasks.isEmpty) {
      return _buildEmptyState(state);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tasksProvider.notifier).loadTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(
              task: task,
              onTap: () => _navigateToTaskForm(task: task),
              onToggleComplete: () => _toggleTaskCompletion(task),
              onDelete: () => _deleteTask(task),
            ),
          );
        },
      ),
    );
  }

  /// Constrói o estado vazio com mensagem contextual.
  Widget _buildEmptyState(TasksState state) {
    String message;
    IconData icon;

    if (state.tasks.isEmpty) {
      message = 'Nenhuma tarefa encontrada\nToque no botão + para criar';
      icon = Icons.task_outlined;
    } else {
      // Tem tarefas mas o filtro não encontrou nada
      switch (state.statusFilter) {
        case TaskStatusFilter.pending:
          message = 'Parabéns! Nenhuma tarefa pendente 🎉';
          icon = Icons.celebration;
          break;
        case TaskStatusFilter.completed:
          message = 'Nenhuma tarefa concluída ainda';
          icon = Icons.check_circle_outline;
          break;
        case TaskStatusFilter.today:
          message = 'Nenhuma tarefa para hoje';
          icon = Icons.today;
          break;
        case TaskStatusFilter.overdue:
          message = 'Nenhuma tarefa atrasada 👍';
          icon = Icons.thumb_up;
          break;
        default:
          message = 'Nenhuma tarefa com estes filtros';
          icon = Icons.filter_list;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          if (state.statusFilter != TaskStatusFilter.all ||
              state.priorityFilter != null ||
              state.categoryFilter != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.read(tasksProvider.notifier).clearFilters(),
              icon: const Icon(Icons.filter_list_off),
              label: const Text('Limpar filtros'),
            ),
          ],
        ],
      ),
    );
  }
}
