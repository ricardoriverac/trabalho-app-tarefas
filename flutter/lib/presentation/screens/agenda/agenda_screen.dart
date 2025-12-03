/// Tela de agenda/visualização de tarefas por data.
///
/// Esta tela exibe as tarefas organizadas por data,
/// permitindo uma visualização tipo calendário/agenda.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/task_card.dart';
import '../task/task_form_screen.dart';

/// Tela de agenda com visualização de tarefas por data.
///
/// Exibe tarefas agrupadas por dia com navegação entre datas.
class AgendaScreen extends ConsumerStatefulWidget {
  /// Construtor padrão.
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  /// Data selecionada atualmente.
  late DateTime _selectedDate;

  /// Controller do PageView para navegação entre semanas.
  late PageController _pageController;

  /// Formato para exibir o mês.
  final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'pt_BR');

  /// Formato para exibir o dia da semana.
  final DateFormat _dayFormat = DateFormat('EEE', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController = PageController(initialPage: 500); // Começa no meio
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Retorna as tarefas para a data selecionada.
  List<TaskModel> _getTasksForDate(List<TaskModel> allTasks, DateTime date) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  /// Retorna tarefas sem data definida.
  List<TaskModel> _getTasksWithoutDate(List<TaskModel> allTasks) {
    return allTasks.where((task) => task.dueDate == null).toList();
  }

  /// Navega para uma data específica.
  void _goToDate(DateTime date) {
    setState(() => _selectedDate = date);
  }

  /// Navega para hoje.
  void _goToToday() {
    setState(() => _selectedDate = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final allTasks = tasksState.tasks.where((t) => !t.completed).toList();
    final tasksForDate = _getTasksForDate(allTasks, _selectedDate);
    final tasksWithoutDate = _getTasksWithoutDate(allTasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: 'Ir para hoje',
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabeçalho com mês
          _buildMonthHeader(),

          // Seletor de dias da semana
          _buildWeekSelector(),

          // Lista de tarefas
          Expanded(
            child: _buildTasksList(tasksForDate, tasksWithoutDate),
          ),
        ],
      ),
    );
  }

  /// Navega para a semana anterior.
  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
  }

  /// Navega para a próxima semana.
  void _goToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
  }

  /// Constrói o cabeçalho com o mês atual.
  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão para semana anterior
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousWeek,
            tooltip: 'Semana anterior',
          ),
          // Título clicável para abrir seletor de data
          GestureDetector(
            onTap: _selectDate,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _monthFormat.format(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          // Botão para próxima semana
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _goToNextWeek,
            tooltip: 'Próxima semana',
          ),
        ],
      ),
    );
  }

  /// Abre o seletor de data para navegação rápida.
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Constrói o seletor de dias da semana.
  Widget _buildWeekSelector() {
    // Calcula o início da semana (segunda-feira)
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return _buildDayItem(date, isSelected, isToday);
        }),
      ),
    );
  }

  /// Constrói um item de dia.
  Widget _buildDayItem(DateTime date, bool isSelected, bool isToday) {
    return GestureDetector(
      onTap: () => _goToDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isToday
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              _dayFormat.format(date).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a lista de tarefas.
  Widget _buildTasksList(
    List<TaskModel> tasksForDate,
    List<TaskModel> tasksWithoutDate,
  ) {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final isPast = _selectedDate.isBefore(DateTime(now.year, now.month, now.day));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resumo do dia
        _buildDaySummary(tasksForDate, isToday, isPast),
        const SizedBox(height: 16),

        // Tarefas do dia
        if (tasksForDate.isNotEmpty) ...[
          _buildSectionTitle('Tarefas do dia'),
          const SizedBox(height: 8),
          ...tasksForDate.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskCard(
                  task: task,
                  onTap: () => _navigateToTaskForm(task),
                  onToggleComplete: () => _toggleTask(task),
                  onDelete: () => _deleteTask(task),
                ),
              )),
        ] else ...[
          _buildEmptyState(isToday, isPast),
        ],

        // Tarefas sem data (apenas se for hoje)
        if (isToday && tasksWithoutDate.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Sem data definida'),
          const SizedBox(height: 8),
          ...tasksWithoutDate.take(5).map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskCard(
                  task: task,
                  onTap: () => _navigateToTaskForm(task),
                  onToggleComplete: () => _toggleTask(task),
                  onDelete: () => _deleteTask(task),
                ),
              )),
          if (tasksWithoutDate.length > 5)
            TextButton(
              onPressed: () {
                // Navega para lista completa
                Navigator.pop(context);
              },
              child: Text('Ver todas (${tasksWithoutDate.length})'),
            ),
        ],
      ],
    );
  }

  /// Constrói o resumo do dia.
  Widget _buildDaySummary(
    List<TaskModel> tasks,
    bool isToday,
    bool isPast,
  ) {
    final dateFormat = DateFormat('EEEE, d MMMM', 'pt_BR');
    final highPriority = tasks.where((t) => t.priority == 'high').length;

    String message;
    IconData icon;
    Color color;

    if (tasks.isEmpty) {
      message = isPast ? 'Nenhuma tarefa para este dia' : 'Dia livre!';
      icon = isPast ? Icons.history : Icons.event_available;
      color = Colors.grey;
    } else if (isToday) {
      message = '${tasks.length} tarefa${tasks.length > 1 ? 's' : ''} para hoje';
      icon = Icons.today;
      color = highPriority > 0 ? AppTheme.warningColor : AppTheme.primaryColor;
    } else if (isPast) {
      message = '${tasks.length} tarefa${tasks.length > 1 ? 's' : ''} atrasada${tasks.length > 1 ? 's' : ''}';
      icon = Icons.warning_amber;
      color = AppTheme.errorColor;
    } else {
      message = '${tasks.length} tarefa${tasks.length > 1 ? 's' : ''} agendada${tasks.length > 1 ? 's' : ''}';
      icon = Icons.event;
      color = AppTheme.primaryColor;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(color: color),
                  ),
                  if (highPriority > 0)
                    Text(
                      '$highPriority de alta prioridade',
                      style: TextStyle(
                        color: AppTheme.highPriorityColor,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o título de uma seção.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  /// Constrói o estado vazio.
  Widget _buildEmptyState(bool isToday, bool isPast) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              isPast ? Icons.history : Icons.event_available,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isPast
                  ? 'Nenhuma tarefa para este dia'
                  : isToday
                      ? 'Nenhuma tarefa para hoje!'
                      : 'Nenhuma tarefa agendada',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  /// Navega para o formulário de tarefa.
  Future<void> _navigateToTaskForm(TaskModel task) async {
    final userId = task.userId;

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

  /// Alterna o status de conclusão.
  Future<void> _toggleTask(TaskModel task) async {
    await ref
        .read(tasksProvider.notifier)
        .toggleTaskCompletion(task.id, !task.completed);
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
      await ref.read(tasksProvider.notifier).deleteTask(task.id);
    }
  }
}

