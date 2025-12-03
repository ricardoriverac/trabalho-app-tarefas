/// Provider de estatísticas usando Riverpod.
///
/// Este arquivo gerencia o estado das estatísticas e métricas
/// de produtividade do usuário.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_model.dart';
import 'task_provider.dart';

/// Modelo de estatísticas do usuário.
class UserStats {
  /// Total de tarefas criadas.
  final int totalTasks;

  /// Tarefas concluídas.
  final int completedTasks;

  /// Tarefas pendentes.
  final int pendingTasks;

  /// Tarefas atrasadas.
  final int overdueTasks;

  /// Tarefas de alta prioridade pendentes.
  final int highPriorityPending;

  /// Taxa de conclusão (0.0 a 1.0).
  final double completionRate;

  /// Tarefas concluídas por dia da semana (Dom=0, Seg=1, ..., Sab=6).
  final Map<int, int> completedByWeekday;

  /// Tarefas por categoria.
  final Map<String, int> tasksByCategory;

  /// Tarefas por prioridade.
  final Map<String, int> tasksByPriority;

  /// Streak atual (dias consecutivos com tarefas concluídas).
  final int currentStreak;

  /// Maior streak já alcançado.
  final int bestStreak;

  /// Média de tarefas concluídas por dia (últimos 7 dias).
  final double avgTasksPerDay;

  /// Tarefas concluídas hoje.
  final int completedToday;

  /// Tarefas para hoje.
  final int dueToday;

  const UserStats({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.pendingTasks = 0,
    this.overdueTasks = 0,
    this.highPriorityPending = 0,
    this.completionRate = 0.0,
    this.completedByWeekday = const {},
    this.tasksByCategory = const {},
    this.tasksByPriority = const {},
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.avgTasksPerDay = 0.0,
    this.completedToday = 0,
    this.dueToday = 0,
  });
}

/// Provider que calcula estatísticas baseado nas tarefas.
final statsProvider = Provider<UserStats>((ref) {
  final tasksState = ref.watch(tasksProvider);
  final tasks = tasksState.tasks;

  if (tasks.isEmpty) {
    return const UserStats();
  }

  // Contadores básicos
  final completedTasks = tasks.where((t) => t.completed).toList();
  final pendingTasks = tasks.where((t) => !t.completed).toList();
  final overdueTasks = tasks.where((t) => t.isOverdue).toList();
  final highPriorityPending =
      pendingTasks.where((t) => t.priority == 'high').length;

  // Taxa de conclusão
  final completionRate =
      tasks.isNotEmpty ? completedTasks.length / tasks.length : 0.0;

  // Tarefas por dia da semana (baseado em updatedAt para concluídas)
  final completedByWeekday = <int, int>{};
  for (var i = 0; i < 7; i++) {
    completedByWeekday[i] = 0;
  }
  for (final task in completedTasks) {
    if (task.updatedAt != null) {
      final weekday = task.updatedAt!.weekday % 7; // Dom=0, Seg=1, etc.
      completedByWeekday[weekday] = (completedByWeekday[weekday] ?? 0) + 1;
    }
  }

  // Tarefas por categoria
  final tasksByCategory = <String, int>{};
  for (final task in tasks) {
    final categoryName = task.category?.name ?? 'Sem categoria';
    tasksByCategory[categoryName] = (tasksByCategory[categoryName] ?? 0) + 1;
  }

  // Tarefas por prioridade
  final tasksByPriority = <String, int>{
    'high': tasks.where((t) => t.priority == 'high').length,
    'medium': tasks.where((t) => t.priority == 'medium').length,
    'low': tasks.where((t) => t.priority == 'low').length,
  };

  // Streak de conclusão
  final streakData = _calculateStreak(completedTasks);

  // Média de tarefas por dia (últimos 7 dias)
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final completedLastWeek = completedTasks.where((t) {
    return t.updatedAt != null && t.updatedAt!.isAfter(weekAgo);
  }).length;
  final avgTasksPerDay = completedLastWeek / 7;

  // Tarefas de hoje
  final today = DateTime(now.year, now.month, now.day);
  final completedToday = completedTasks.where((t) {
    if (t.updatedAt == null) return false;
    final taskDate =
        DateTime(t.updatedAt!.year, t.updatedAt!.month, t.updatedAt!.day);
    return taskDate.isAtSameMomentAs(today);
  }).length;

  final dueToday = tasks.where((t) => t.isDueToday).length;

  return UserStats(
    totalTasks: tasks.length,
    completedTasks: completedTasks.length,
    pendingTasks: pendingTasks.length,
    overdueTasks: overdueTasks.length,
    highPriorityPending: highPriorityPending,
    completionRate: completionRate,
    completedByWeekday: completedByWeekday,
    tasksByCategory: tasksByCategory,
    tasksByPriority: tasksByPriority,
    currentStreak: streakData['current'] ?? 0,
    bestStreak: streakData['best'] ?? 0,
    avgTasksPerDay: avgTasksPerDay,
    completedToday: completedToday,
    dueToday: dueToday,
  );
});

/// Calcula o streak de dias consecutivos com tarefas concluídas.
Map<String, int> _calculateStreak(List<TaskModel> completedTasks) {
  if (completedTasks.isEmpty) {
    return {'current': 0, 'best': 0};
  }

  // Agrupa tarefas por data de conclusão
  final tasksByDate = <DateTime, int>{};
  for (final task in completedTasks) {
    if (task.updatedAt != null) {
      final date = DateTime(
        task.updatedAt!.year,
        task.updatedAt!.month,
        task.updatedAt!.day,
      );
      tasksByDate[date] = (tasksByDate[date] ?? 0) + 1;
    }
  }

  if (tasksByDate.isEmpty) {
    return {'current': 0, 'best': 0};
  }

  // Ordena as datas
  final dates = tasksByDate.keys.toList()..sort();

  // Calcula streaks
  int currentStreak = 0;
  int bestStreak = 0;
  int tempStreak = 1;

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final yesterday = todayDate.subtract(const Duration(days: 1));

  // Verifica se hoje ou ontem tem tarefas (para streak atual)
  final hasToday = tasksByDate.containsKey(todayDate);
  final hasYesterday = tasksByDate.containsKey(yesterday);

  if (hasToday || hasYesterday) {
    // Conta o streak atual de trás para frente
    var checkDate = hasToday ? todayDate : yesterday;
    currentStreak = 1;

    while (true) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (tasksByDate.containsKey(checkDate)) {
        currentStreak++;
      } else {
        break;
      }
    }
  }

  // Calcula o melhor streak histórico
  for (var i = 1; i < dates.length; i++) {
    final diff = dates[i].difference(dates[i - 1]).inDays;
    if (diff == 1) {
      tempStreak++;
    } else {
      if (tempStreak > bestStreak) {
        bestStreak = tempStreak;
      }
      tempStreak = 1;
    }
  }
  if (tempStreak > bestStreak) {
    bestStreak = tempStreak;
  }

  // O melhor streak deve ser pelo menos o atual
  if (currentStreak > bestStreak) {
    bestStreak = currentStreak;
  }

  return {'current': currentStreak, 'best': bestStreak};
}

