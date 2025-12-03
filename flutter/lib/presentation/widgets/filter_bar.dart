/// Barra de filtros para a lista de tarefas.
///
/// Este widget exibe chips de filtro por status, prioridade,
/// categoria e ordenação.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../providers/category_provider.dart';
import '../providers/task_provider.dart';
import '../themes/app_theme.dart';

/// Barra horizontal com chips de filtro.
///
/// Permite filtrar tarefas por status (todas, pendentes, concluídas, hoje, atrasadas),
/// prioridade (baixa, média, alta) e categoria.
class FilterBar extends ConsumerWidget {
  /// Construtor padrão.
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksProvider);
    final categories = ref.watch(categoriesListProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtros de status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatusChip(
                  context,
                  ref,
                  TaskStatusFilter.all,
                  'Todas',
                  Icons.list,
                  tasksState.statusFilter,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  context,
                  ref,
                  TaskStatusFilter.pending,
                  'Pendentes',
                  Icons.pending_actions,
                  tasksState.statusFilter,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  context,
                  ref,
                  TaskStatusFilter.today,
                  'Hoje',
                  Icons.today,
                  tasksState.statusFilter,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  context,
                  ref,
                  TaskStatusFilter.overdue,
                  'Atrasadas',
                  Icons.warning_amber,
                  tasksState.statusFilter,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  context,
                  ref,
                  TaskStatusFilter.completed,
                  'Concluídas',
                  Icons.check_circle_outline,
                  tasksState.statusFilter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Filtros adicionais (prioridade, categoria, ordenação)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Filtro de prioridade
                _buildPriorityDropdown(context, ref, tasksState.priorityFilter),
                const SizedBox(width: 8),

                // Filtro de categoria
                if (categories.isNotEmpty)
                  _buildCategoryDropdown(
                    context,
                    ref,
                    tasksState.categoryFilter,
                    categories,
                  ),
                const SizedBox(width: 8),

                // Ordenação
                _buildSortDropdown(context, ref, tasksState.sortOrder),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um chip de filtro de status.
  Widget _buildStatusChip(
    BuildContext context,
    WidgetRef ref,
    TaskStatusFilter filter,
    String label,
    IconData icon,
    TaskStatusFilter currentFilter,
  ) {
    final isSelected = filter == currentFilter;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          ref.read(tasksProvider.notifier).setStatusFilter(filter);
        }
      },
    );
  }

  /// Constrói o dropdown de filtro de prioridade.
  Widget _buildPriorityDropdown(
    BuildContext context,
    WidgetRef ref,
    String? currentPriority,
  ) {
    return PopupMenuButton<String?>(
      initialValue: currentPriority,
      onSelected: (value) {
        ref.read(tasksProvider.notifier).setPriorityFilter(value);
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Text('Todas as prioridades'),
        ),
        const PopupMenuDivider(),
        ...TaskPriority.all.map((priority) {
          return PopupMenuItem<String>(
            value: priority,
            child: Row(
              children: [
                Icon(
                  AppTheme.getPriorityIcon(priority),
                  color: AppTheme.getPriorityColor(priority),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(TaskPriority.getLabel(priority)),
              ],
            ),
          );
        }),
      ],
      child: Chip(
        avatar: currentPriority != null
            ? Icon(
                AppTheme.getPriorityIcon(currentPriority),
                size: 16,
                color: AppTheme.getPriorityColor(currentPriority),
              )
            : const Icon(Icons.flag_outlined, size: 16),
        label: Text(
          currentPriority != null
              ? TaskPriority.getLabel(currentPriority)
              : 'Prioridade',
        ),
        deleteIcon: currentPriority != null
            ? const Icon(Icons.close, size: 16)
            : null,
        onDeleted: currentPriority != null
            ? () => ref.read(tasksProvider.notifier).setPriorityFilter(null)
            : null,
      ),
    );
  }

  /// Constrói o dropdown de filtro de categoria.
  Widget _buildCategoryDropdown(
    BuildContext context,
    WidgetRef ref,
    String? currentCategory,
    List categories,
  ) {
    final selectedCategory = currentCategory != null
        ? categories.where((c) => c.id == currentCategory).firstOrNull
        : null;

    return PopupMenuButton<String?>(
      initialValue: currentCategory,
      onSelected: (value) {
        ref.read(tasksProvider.notifier).setCategoryFilter(value);
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Text('Todas as categorias'),
        ),
        const PopupMenuDivider(),
        ...categories.map((category) {
          return PopupMenuItem<String?>(
            value: category.id,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: category.colorValue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(category.name),
              ],
            ),
          );
        }),
      ],
      child: Chip(
        avatar: selectedCategory != null
            ? Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: selectedCategory.colorValue,
                  shape: BoxShape.circle,
                ),
              )
            : const Icon(Icons.folder_outlined, size: 16),
        label: Text(selectedCategory?.name ?? 'Categoria'),
        deleteIcon: currentCategory != null
            ? const Icon(Icons.close, size: 16)
            : null,
        onDeleted: currentCategory != null
            ? () => ref.read(tasksProvider.notifier).setCategoryFilter(null)
            : null,
      ),
    );
  }

  /// Constrói o dropdown de ordenação.
  Widget _buildSortDropdown(
    BuildContext context,
    WidgetRef ref,
    TaskSortOrder currentSort,
  ) {
    String getSortLabel(TaskSortOrder sort) {
      switch (sort) {
        case TaskSortOrder.priority:
          return 'Prioridade';
        case TaskSortOrder.dueDate:
          return 'Data limite';
        case TaskSortOrder.createdAt:
          return 'Data de criação';
        case TaskSortOrder.title:
          return 'Título';
      }
    }

    return PopupMenuButton<TaskSortOrder>(
      initialValue: currentSort,
      onSelected: (value) {
        ref.read(tasksProvider.notifier).setSortOrder(value);
      },
      itemBuilder: (context) => TaskSortOrder.values.map((sort) {
        return PopupMenuItem<TaskSortOrder>(
          value: sort,
          child: Row(
            children: [
              if (sort == currentSort)
                const Icon(Icons.check, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(getSortLabel(sort)),
            ],
          ),
        );
      }).toList(),
      child: Chip(
        avatar: const Icon(Icons.sort, size: 16),
        label: Text(getSortLabel(currentSort)),
      ),
    );
  }
}

