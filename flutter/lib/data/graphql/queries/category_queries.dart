/// Queries GraphQL para operações de leitura de categorias.
///
/// Este arquivo contém todas as queries relacionadas à entidade Category.
library;

/// Query para buscar todas as categorias de um usuário.
const String getCategoriesQuery = r'''
  query GetCategories($userId: uuid!) {
    categories(
      where: { user_id: { _eq: $userId } }
      order_by: { name: asc }
    ) {
      id
      user_id
      name
      color
      created_at
    }
  }
''';

/// Query para buscar uma categoria por ID.
const String getCategoryByIdQuery = r'''
  query GetCategoryById($id: uuid!) {
    categories_by_pk(id: $id) {
      id
      user_id
      name
      color
      created_at
    }
  }
''';

/// Query para buscar categorias com contagem de tarefas.
const String getCategoriesWithTaskCountQuery = r'''
  query GetCategoriesWithTaskCount($userId: uuid!) {
    categories(
      where: { user_id: { _eq: $userId } }
      order_by: { name: asc }
    ) {
      id
      user_id
      name
      color
      created_at
      tasks_aggregate {
        aggregate {
          count
        }
      }
      pending_tasks: tasks_aggregate(
        where: { completed: { _eq: false } }
      ) {
        aggregate {
          count
        }
      }
    }
  }
''';

