/// Mutations GraphQL para operações de escrita de categorias.
///
/// Este arquivo contém todas as mutations relacionadas à entidade Category.
library;

/// Mutation para criar uma nova categoria.
const String createCategoryMutation = r'''
  mutation CreateCategory($category: categories_insert_input!) {
    insert_categories_one(object: $category) {
      id
      user_id
      name
      color
      created_at
    }
  }
''';

/// Mutation para atualizar uma categoria existente.
const String updateCategoryMutation = r'''
  mutation UpdateCategory($id: uuid!, $changes: categories_set_input!) {
    update_categories_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      user_id
      name
      color
      created_at
    }
  }
''';

/// Mutation para deletar uma categoria.
///
/// Reason: Ao deletar uma categoria, as tarefas associadas terão
/// category_id definido como NULL (ON DELETE SET NULL).
const String deleteCategoryMutation = r'''
  mutation DeleteCategory($id: uuid!) {
    delete_categories_by_pk(id: $id) {
      id
    }
  }
''';

