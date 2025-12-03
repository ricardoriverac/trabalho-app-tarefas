/// Tela de Dashboard com estatísticas e métricas.
///
/// Exibe um resumo visual da produtividade do usuário
/// com gráficos, cards de estatísticas e streak.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stats_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/charts/bar_chart_widget.dart';
import '../../widgets/charts/progress_ring_widget.dart';
import '../../widgets/charts/stat_card_widget.dart';

/// Tela principal do dashboard.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Força recarregamento das tarefas
          // As estatísticas serão recalculadas automaticamente
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com saudação
              _buildHeader(context, stats),
              const SizedBox(height: 24),

              // Anel de progresso principal
              _buildMainProgress(context, stats),
              const SizedBox(height: 24),

              // Cards de estatísticas rápidas
              _buildQuickStats(context, stats),
              const SizedBox(height: 24),

              // Streak
              _buildStreakSection(context, stats),
              const SizedBox(height: 24),

              // Gráfico de atividade semanal
              _buildWeeklyActivity(context, stats, theme),
              const SizedBox(height: 24),

              // Tarefas por categoria
              _buildCategoryBreakdown(context, stats, theme),
              const SizedBox(height: 24),

              // Tarefas por prioridade
              _buildPriorityBreakdown(context, stats),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o cabeçalho com saudação.
  Widget _buildHeader(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Bom dia! ☀️';
    } else if (hour < 18) {
      greeting = 'Boa tarde! 🌤️';
    } else {
      greeting = 'Boa noite! 🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stats.dueToday > 0
              ? 'Você tem ${stats.dueToday} ${stats.dueToday == 1 ? 'tarefa' : 'tarefas'} para hoje'
              : 'Nenhuma tarefa pendente para hoje',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Constrói o anel de progresso principal.
  Widget _buildMainProgress(BuildContext context, UserStats stats) {
    return Center(
      child: Column(
        children: [
          ProgressRingWidget(
            progress: stats.completionRate,
            size: 180,
            strokeWidth: 16,
            progressColor: _getProgressColor(stats.completionRate),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressLegend(
                context,
                'Concluídas',
                stats.completedTasks,
                Colors.green,
              ),
              const SizedBox(width: 32),
              _buildProgressLegend(
                context,
                'Pendentes',
                stats.pendingTasks,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói um item de legenda do progresso.
  Widget _buildProgressLegend(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  /// Retorna a cor baseada na taxa de conclusão.
  Color _getProgressColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.5) return Colors.blue;
    if (rate >= 0.3) return Colors.orange;
    return Colors.red;
  }

  /// Constrói os cards de estatísticas rápidas.
  Widget _buildQuickStats(BuildContext context, UserStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        StatCardWidget(
          title: 'Hoje',
          value: '${stats.completedToday}',
          subtitle: 'concluídas',
          icon: Icons.today,
          color: Colors.blue,
          filled: true,
        ),
        StatCardWidget(
          title: 'Atrasadas',
          value: '${stats.overdueTasks}',
          subtitle: stats.overdueTasks > 0 ? 'atenção!' : 'tudo em dia',
          icon: Icons.warning_amber,
          color: stats.overdueTasks > 0 ? Colors.red : Colors.green,
          filled: stats.overdueTasks > 0,
        ),
        StatCardWidget(
          title: 'Alta prioridade',
          value: '${stats.highPriorityPending}',
          subtitle: 'pendentes',
          icon: Icons.priority_high,
          color: Colors.orange,
        ),
        StatCardWidget(
          title: 'Média/dia',
          value: stats.avgTasksPerDay.toStringAsFixed(1),
          subtitle: 'últimos 7 dias',
          icon: Icons.show_chart,
          color: Colors.purple,
        ),
      ],
    );
  }

  /// Constrói a seção de streak.
  Widget _buildStreakSection(BuildContext context, UserStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔥 Sequência',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        StreakCardWidget(
          currentStreak: stats.currentStreak,
          bestStreak: stats.bestStreak,
        ),
      ],
    );
  }

  /// Constrói o gráfico de atividade semanal.
  Widget _buildWeeklyActivity(
    BuildContext context,
    UserStats stats,
    ThemeData theme,
  ) {
    // Dias da semana em português (Dom = 0)
    const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final today = DateTime.now().weekday % 7;

    final items = List.generate(7, (index) {
      final count = stats.completedByWeekday[index] ?? 0;
      return BarChartItem(
        label: weekdays[index],
        value: count.toDouble(),
        color: index == today ? theme.colorScheme.primary : Colors.blue.shade300,
      );
    });

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Atividade Semanal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tarefas concluídas por dia da semana',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            BarChartWidget(
              items: items,
              maxBarHeight: 120,
              barWidth: 28,
              defaultColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o breakdown por categoria.
  Widget _buildCategoryBreakdown(
    BuildContext context,
    UserStats stats,
    ThemeData theme,
  ) {
    if (stats.tasksByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordena por quantidade
    final sortedCategories = stats.tasksByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Cores para categorias
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    final items = sortedCategories.take(6).toList().asMap().entries.map((e) {
      return BarChartItem(
        label: e.value.key,
        value: e.value.value.toDouble(),
        color: colors[e.key % colors.length],
      );
    }).toList();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Por Categoria',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Distribuição de tarefas',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            HorizontalBarChartWidget(
              items: items,
              barHeight: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o breakdown por prioridade.
  Widget _buildPriorityBreakdown(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    final high = stats.tasksByPriority['high'] ?? 0;
    final medium = stats.tasksByPriority['medium'] ?? 0;
    final low = stats.tasksByPriority['low'] ?? 0;
    final total = high + medium + low;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Por Prioridade',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barra de progresso empilhada
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: [
                    if (high > 0)
                      Expanded(
                        flex: high,
                        child: Container(
                          color: Colors.red,
                          alignment: Alignment.center,
                          child: Text(
                            '$high',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (medium > 0)
                      Expanded(
                        flex: medium,
                        child: Container(
                          color: Colors.orange,
                          alignment: Alignment.center,
                          child: Text(
                            '$medium',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (low > 0)
                      Expanded(
                        flex: low,
                        child: Container(
                          color: Colors.green,
                          alignment: Alignment.center,
                          child: Text(
                            '$low',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriorityLegend(context, 'Alta', high, Colors.red),
                _buildPriorityLegend(context, 'Média', medium, Colors.orange),
                _buildPriorityLegend(context, 'Baixa', low, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um item de legenda de prioridade.
  Widget _buildPriorityLegend(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

