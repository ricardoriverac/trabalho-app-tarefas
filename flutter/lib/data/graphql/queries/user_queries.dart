/// Queries GraphQL para operações de leitura de usuários.
///
/// Este arquivo contém todas as queries relacionadas à entidade User.
library;

/// Query para buscar um usuário por ID.
const String getUserByIdQuery = r'''
  query GetUserById($id: uuid!) {
    users_by_pk(id: $id) {
      id
      name
      email
      created_at
    }
  }
''';

/// Query para buscar um usuário por email.
const String getUserByEmailQuery = r'''
  query GetUserByEmail($email: String!) {
    users(where: { email: { _eq: $email } }) {
      id
      name
      email
      created_at
    }
  }
''';

/// Query para buscar estatísticas do usuário.
const String getUserStatsQuery = r'''
  query GetUserStats($userId: uuid!, $weekStart: timestamptz!, $weekEnd: timestamptz!) {
    user: users_by_pk(id: $userId) {
      id
      name
      email
    }
    total_tasks: tasks_aggregate(where: { user_id: { _eq: $userId } }) {
      aggregate {
        count
      }
    }
    completed_tasks: tasks_aggregate(
      where: { 
        user_id: { _eq: $userId }, 
        completed: { _eq: true } 
      }
    ) {
      aggregate {
        count
      }
    }
    week_completed: task_history_aggregate(
      where: {
        task: { user_id: { _eq: $userId } },
        completed_at: { _gte: $weekStart, _lte: $weekEnd }
      }
    ) {
      aggregate {
        count
        avg {
          duration_minutes
          productivity_score
        }
      }
    }
    categories_count: categories_aggregate(
      where: { user_id: { _eq: $userId } }
    ) {
      aggregate {
        count
      }
    }
  }
''';

