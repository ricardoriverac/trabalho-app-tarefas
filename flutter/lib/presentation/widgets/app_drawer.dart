/// Menu lateral (Drawer) do aplicativo.
///
/// Este widget exibe o menu de navegação principal com:
/// - Informações do usuário
/// - Filtros rápidos de tarefas
/// - Navegação para categorias
/// - Opção de logout
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/task_provider.dart';
import '../screens/agenda/agenda_screen.dart';
import '../screens/category/categories_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/home/home_screen.dart';
import '../themes/app_theme.dart';

/// Menu lateral principal do aplicativo.
///
/// Fornece navegação rápida entre diferentes visualizações
/// e funcionalidades do app.
class AppDrawer extends ConsumerWidget {
  /// Construtor padrão.
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final taskCounts = ref.watch(taskCountsProvider);
    final categories = ref.watch(categoriesListProvider);

    return Drawer(
      child: Column(
        children: [
          // Header com informações do usuário
          _buildHeader(context, user?.name, user?.email),

          // Lista de itens do menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Seção: Tarefas
                _buildSectionTitle(context, 'Tarefas'),

                _buildMenuItem(
                  context,
                  ref,
                  icon: Icons.list,
                  title: 'Todas as Tarefas',
                  count: taskCounts['total'],
                  onTap: () {
                    ref.read(tasksProvider.notifier).clearFilters();
                    // Volta para a Home removendo todas as telas acima
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  ref,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  ref,
                  icon: Icons.calendar_month,
                  title: 'Agenda',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgendaScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  ref,
                  icon: Icons.pending_actions,
                  title: 'Pendentes',
                  count: taskCounts['pending'],
                  color: AppTheme.primaryColor,
                  onTap: () {
                    ref
                        .read(tasksProvider.notifier)
                        .setStatusFilter(TaskStatusFilter.pending);
                    _navigateToHome(context);
                  },
                ),

                _buildMenuItem(
                  context,
                  ref,
                  icon: Icons.today,
                  title: 'Para Hoje',
                  count: taskCounts['today'],
                  color: AppTheme.warningColor,
                  onTap: () {
                    ref
                        .read(tasksProvider.notifier)
                        .setStatusFilter(TaskStatusFilter.today);
                    _navigateToHome(context);
                  },
                ),

                _buildMenuItem(
                  context,
                  ref,
                  icon: Icons.warning_amber,
                  title: 'Atrasadas',
                  count: taskCounts['overdue'],
                  color: AppTheme.errorColor,
                  onTap: () {
                    ref
                        .read(tasksProvider.notifier)
                        .setStatusFilter(TaskStatusFilter.overdue);
                    _navigateToHome(context);
                  },
                ),

                _buildMenuItem(
                  context,
                  ref,
                  icon: Icons.check_circle_outline,
                  title: 'Concluídas',
                  count: taskCounts['completed'],
                  color: AppTheme.successColor,
                  onTap: () {
                    ref
                        .read(tasksProvider.notifier)
                        .setStatusFilter(TaskStatusFilter.completed);
                    _navigateToHome(context);
                  },
                ),

                const Divider(),

                // Seção: Categorias
                _buildSectionTitle(context, 'Categorias'),

                // Item para gerenciar categorias
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Gerenciar Categorias'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesScreen(),
                      ),
                    );
                  },
                ),

                // Lista de categorias
                ...categories.map((category) {
                  return _buildCategoryItem(context, ref, category);
                }),

                if (categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nenhuma categoria criada',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ),

                const Divider(),

                // Seção: Prioridades
                _buildSectionTitle(context, 'Por Prioridade'),

                _buildPriorityItem(
                  context,
                  ref,
                  priority: 'high',
                  title: 'Alta',
                  color: AppTheme.highPriorityColor,
                ),
                _buildPriorityItem(
                  context,
                  ref,
                  priority: 'medium',
                  title: 'Média',
                  color: AppTheme.mediumPriorityColor,
                ),
                _buildPriorityItem(
                  context,
                  ref,
                  priority: 'low',
                  title: 'Baixa',
                  color: AppTheme.lowPriorityColor,
                ),
              ],
            ),
          ),

          // Footer com logout
          _buildFooter(context, ref),
        ],
      ),
    );
  }

  /// Constrói o header do drawer com informações do usuário.
  Widget _buildHeader(BuildContext context, String? name, String? email) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(
              Icons.person,
              size: 36,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),

          // Nome do usuário
          Text(
            name ?? 'Usuário',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Email
          if (email != null)
            Text(
              email,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  /// Constrói um título de seção.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// Constrói um item de menu.
  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    int? count,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: count != null && count > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (color ?? Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: color ?? Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  /// Constrói um item de categoria.
  Widget _buildCategoryItem(
    BuildContext context,
    WidgetRef ref,
    dynamic category,
  ) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: category.colorValue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.folder,
          size: 16,
          color: category.colorValue,
        ),
      ),
      title: Text(category.name),
      onTap: () {
        ref.read(tasksProvider.notifier).setCategoryFilter(category.id);
        _navigateToHome(context);
      },
    );
  }

  /// Constrói um item de prioridade.
  Widget _buildPriorityItem(
    BuildContext context,
    WidgetRef ref, {
    required String priority,
    required String title,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(
        AppTheme.getPriorityIcon(priority),
        color: color,
      ),
      title: Text('Prioridade $title'),
      onTap: () {
        ref.read(tasksProvider.notifier).setPriorityFilter(priority);
        _navigateToHome(context);
      },
    );
  }

  /// Navega para a Home removendo todas as telas acima.
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  /// Constrói o footer com opções adicionais.
  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre'),
              subtitle: Text(
                '${AppConfig.appName} v${AppConfig.appVersion}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorColor),
              title: const Text(
                'Sair',
                style: TextStyle(color: AppTheme.errorColor),
              ),
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
}

