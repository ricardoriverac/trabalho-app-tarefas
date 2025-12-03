/// Widget de card para exibir uma tarefa.
///
/// Este widget exibe as informações principais de uma tarefa
/// com opções de interação (marcar como concluída, editar, excluir).
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/task_model.dart';
import '../themes/app_theme.dart';

/// Card que exibe uma tarefa com suas informações.
///
/// Mostra título, descrição, prioridade, data limite e categoria,
/// com indicadores visuais para tarefas atrasadas ou urgentes.
class TaskCard extends StatelessWidget {
  /// Modelo da tarefa a ser exibida.
  final TaskModel task;

  /// Callback ao tocar no card.
  final VoidCallback? onTap;

  /// Callback ao marcar/desmarcar como concluída.
  final VoidCallback? onToggleComplete;

  /// Callback ao excluir a tarefa.
  final VoidCallback? onDelete;

  /// Construtor padrão.
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        onDelete?.call();
        return false; // O delete é tratado pelo callback
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppTheme.getPriorityColor(task.priority),
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox de conclusão
                  _buildCheckbox(context),
                  const SizedBox(width: 12),

                  // Conteúdo principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        _buildTitle(theme),
                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _buildDescription(theme),
                        ],
                        const SizedBox(height: 8),
                        // Tags e informações
                        _buildTags(context, isOverdue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o checkbox de conclusão.
  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: onToggleComplete,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: task.completed
                ? AppTheme.successColor
                : Colors.grey.shade400,
            width: 2,
          ),
          color: task.completed ? AppTheme.successColor : Colors.transparent,
        ),
        child: task.completed
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  /// Constrói o título da tarefa.
  Widget _buildTitle(ThemeData theme) {
    return Text(
      task.title,
      style: theme.textTheme.titleMedium?.copyWith(
        decoration: task.completed ? TextDecoration.lineThrough : null,
        color: task.completed ? Colors.grey : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Constrói a descrição da tarefa.
  Widget _buildDescription(ThemeData theme) {
    return Text(
      task.description!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.grey.shade600,
        decoration: task.completed ? TextDecoration.lineThrough : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Constrói as tags de informação (data, categoria, prioridade).
  Widget _buildTags(BuildContext context, bool isOverdue) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Data limite
        if (task.dueDate != null) _buildDueDateChip(context, isOverdue),

        // Categoria
        if (task.category != null) _buildCategoryChip(context),

        // Contexto
        if (task.context != null) _buildContextChip(context),

        // Prioridade (apenas se alta)
        if (task.isHighPriority && !task.completed)
          _buildPriorityChip(context),
      ],
    );
  }

  /// Constrói o chip de data limite.
  Widget _buildDueDateChip(BuildContext context, bool isOverdue) {
    final dateFormat = DateFormat('dd/MM');
    String label;

    if (task.isDueToday) {
      label = 'Hoje';
    } else if (task.isDueTomorrow) {
      label = 'Amanhã';
    } else {
      label = dateFormat.format(task.dueDate!);
    }

    if (task.dueTime != null) {
      label += ' ${task.dueTime!.substring(0, 5)}';
    }

    return _buildInfoChip(
      icon: Icons.calendar_today,
      label: label,
      backgroundColor: isOverdue
          ? AppTheme.errorColor.withValues(alpha: 0.1)
          : Colors.grey.shade100,
      textColor: isOverdue ? AppTheme.errorColor : Colors.grey.shade700,
    );
  }

  /// Constrói o chip de categoria.
  Widget _buildCategoryChip(BuildContext context) {
    return _buildInfoChip(
      icon: Icons.folder_outlined,
      label: task.category!.name,
      backgroundColor: task.category!.colorValue.withValues(alpha: 0.1),
      textColor: task.category!.colorValue,
    );
  }

  /// Constrói o chip de contexto.
  Widget _buildContextChip(BuildContext context) {
    return _buildInfoChip(
      icon: Icons.place_outlined,
      label: task.context!,
      backgroundColor: Colors.blue.shade50,
      textColor: Colors.blue.shade700,
    );
  }

  /// Constrói o chip de prioridade alta.
  Widget _buildPriorityChip(BuildContext context) {
    return _buildInfoChip(
      icon: Icons.priority_high,
      label: 'Urgente',
      backgroundColor: AppTheme.highPriorityColor.withValues(alpha: 0.1),
      textColor: AppTheme.highPriorityColor,
    );
  }

  /// Constrói um chip de informação genérico.
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

