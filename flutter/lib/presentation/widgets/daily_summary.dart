/// Widget de resumo diário das tarefas.
///
/// Este widget exibe um resumo do dia atual com contadores
/// e indicadores visuais de progresso.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_provider.dart';
import '../themes/app_theme.dart';

/// Widget que exibe um resumo das tarefas do dia.
///
/// Mostra contadores de tarefas pendentes, concluídas,
/// atrasadas e de alta prioridade com indicadores visuais.
class DailySummary extends ConsumerWidget {
  /// Construtor padrão.
  const DailySummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(taskCountsProvider);

    final pending = counts['pending'] ?? 0;
    final completed = counts['completed'] ?? 0;
    final overdue = counts['overdue'] ?? 0;
    final today = counts['today'] ?? 0;
    final highPriority = counts['highPriority'] ?? 0;
    final total = pending + completed;

    // Calcula progresso
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (overdue > 0) _buildAlertBadge(context, overdue),
              ],
            ),
            const SizedBox(height: 16),

            // Barra de progresso
            _buildProgressBar(context, progress, completed, total),
            const SizedBox(height: 16),

            // Estatísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.pending_actions,
                  label: 'Pendentes',
                  value: pending.toString(),
                  color: AppTheme.primaryColor,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.today,
                  label: 'Para Hoje',
                  value: today.toString(),
                  color: AppTheme.warningColor,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.priority_high,
                  label: 'Urgentes',
                  value: highPriority.toString(),
                  color: AppTheme.highPriorityColor,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.check_circle,
                  label: 'Feitas',
                  value: completed.toString(),
                  color: AppTheme.successColor,
                ),
              ],
            ),

            // Mensagem motivacional
            if (pending == 0 && completed > 0) ...[
              const SizedBox(height: 16),
              _buildCongratulations(context),
            ],

            // Alerta de tarefas atrasadas
            if (overdue > 0) ...[
              const SizedBox(height: 16),
              _buildOverdueAlert(context, overdue),
            ],
          ],
        ),
      ),
    );
  }

  /// Retorna a saudação baseada na hora do dia.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia!';
    if (hour < 18) return 'Boa tarde!';
    return 'Boa noite!';
  }

  /// Constrói o badge de alerta.
  Widget _buildAlertBadge(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '$count atrasada${count > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a barra de progresso.
  Widget _buildProgressBar(
    BuildContext context,
    double progress,
    int completed,
    int total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso do dia',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            Text(
              '$completed de $total tarefas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? AppTheme.successColor : AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói um item de estatística.
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  /// Constrói a mensagem de parabéns.
  Widget _buildCongratulations(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.celebration,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Parabéns! Você completou todas as tarefas pendentes! 🎉',
              style: TextStyle(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o alerta de tarefas atrasadas.
  Widget _buildOverdueAlert(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppTheme.errorColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você tem $count tarefa${count > 1 ? 's' : ''} atrasada${count > 1 ? 's' : ''}. Revise sua agenda!',
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget compacto de resumo para exibir no topo da lista.
class CompactDailySummary extends ConsumerWidget {
  /// Callback ao clicar no resumo.
  final VoidCallback? onTap;

  /// Construtor padrão.
  const CompactDailySummary({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(taskCountsProvider);

    final pending = counts['pending'] ?? 0;
    final overdue = counts['overdue'] ?? 0;
    final today = counts['today'] ?? 0;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícone
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo do dia',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '$pending pendentes • $today para hoje',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),

              // Badge de atrasadas
              if (overdue > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$overdue!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

