/// Tela de listagem de categorias.
///
/// Esta tela exibe todas as categorias do usuário com opções
/// de criar, editar e excluir.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../themes/app_theme.dart';
import 'category_form_screen.dart';

/// Tela de gerenciamento de categorias.
///
/// Permite visualizar, criar, editar e excluir categorias
/// que agrupam as tarefas do usuário.
class CategoriesScreen extends ConsumerStatefulWidget {
  /// Construtor padrão.
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega categorias ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).loadCategories();
    });
  }

  /// Navega para o formulário de categoria.
  Future<void> _navigateToCategoryForm({CategoryModel? category}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(category: category),
      ),
    );

    if (result == true) {
      ref.read(categoriesProvider.notifier).loadCategories();
    }
  }

  /// Exclui uma categoria.
  Future<void> _deleteCategory(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja excluir a categoria "${category.name}"?'),
            const SizedBox(height: 8),
            Text(
              'As tarefas desta categoria não serão excluídas, '
              'apenas ficarão sem categoria.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
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
          .read(categoriesProvider.notifier)
          .deleteCategory(category.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoria excluída com sucesso'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir categoria'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(categoriesProvider.notifier).loadCategories(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(categoriesState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCategoryForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Categoria'),
      ),
    );
  }

  /// Constrói o corpo da tela.
  Widget _buildBody(CategoriesState state) {
    if (state.isLoading && state.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(state.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(categoriesProvider.notifier).loadCategories(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhuma categoria encontrada',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie categorias para organizar suas tarefas',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(categoriesProvider.notifier).loadCategories(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  /// Constrói o card de uma categoria.
  Widget _buildCategoryCard(CategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.colorValue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.folder, color: category.colorValue),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Criada em ${_formatDate(category.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToCategoryForm(category: category);
            } else if (value == 'delete') {
              _deleteCategory(category);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToCategoryForm(category: category),
      ),
    );
  }

  /// Formata a data para exibição.
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
