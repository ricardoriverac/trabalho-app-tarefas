/// Provider de categorias usando Riverpod.
///
/// Este arquivo gerencia o estado das categorias em toda a aplicação.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import 'auth_provider.dart';

// ============================================
// ESTADO DAS CATEGORIAS
// ============================================

/// Estado das categorias.
class CategoriesState {
  /// Lista de categorias.
  final List<CategoryModel> categories;

  /// Indica se está carregando.
  final bool isLoading;

  /// Mensagem de erro, se houver.
  final String? errorMessage;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// Cria uma cópia com campos alterados.
  CategoriesState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ============================================
// NOTIFIER DE CATEGORIAS
// ============================================

/// Notifier responsável por gerenciar o estado das categorias.
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  /// Repositório de categorias.
  final CategoryRepository _categoryRepository;

  /// ID do usuário atual.
  final String? _userId;

  /// Construtor.
  CategoriesNotifier(this._categoryRepository, this._userId)
    : super(const CategoriesState());

  /// Carrega as categorias do usuário.
  Future<void> loadCategories() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final categories = await _categoryRepository.getCategories(_userId);
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar categorias: ${e.toString()}',
      );
    }
  }

  /// Cria uma nova categoria.
  Future<bool> createCategory(CategoryModel category) async {
    try {
      await _categoryRepository.createCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao criar categoria: ${e.toString()}',
      );
      return false;
    }
  }

  /// Atualiza uma categoria.
  Future<bool> updateCategory(
    String categoryId,
    Map<String, dynamic> changes,
  ) async {
    try {
      await _categoryRepository.updateCategory(categoryId, changes);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar categoria: ${e.toString()}',
      );
      return false;
    }
  }

  /// Deleta uma categoria.
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _categoryRepository.deleteCategory(categoryId);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao deletar categoria: ${e.toString()}',
      );
      return false;
    }
  }

  /// Limpa a mensagem de erro.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ============================================
// PROVIDERS
// ============================================

/// Provider do repositório de categorias.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// Provider do estado de categorias.
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
      final repository = ref.watch(categoryRepositoryProvider);
      final userId = ref.watch(currentUserIdProvider);
      return CategoriesNotifier(repository, userId);
    });

/// Provider da lista de categorias.
final categoriesListProvider = Provider<List<CategoryModel>>((ref) {
  final state = ref.watch(categoriesProvider);
  return state.categories;
});
