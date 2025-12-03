/// Queries GraphQL para operações de leitura de tarefas.
///
/// Este arquivo contém todas as queries relacionadas à entidade Task.
library;

/// Query para buscar todas as tarefas de um usuário.
///
/// Inclui a categoria associada via join e ordena por:
/// 1. Tarefas não concluídas primeiro
/// 2. Prioridade (alta → média → baixa)
/// 3. Data limite (mais próxima primeiro)
const String getTasksQuery = r'''
  query GetTasks($userId: uuid!) {
    tasks(
      where: { user_id: { _eq: $userId } }
      order_by: [
        { completed: asc },
        { priority: desc },
        { due_date: asc_nulls_last }
      ]
    ) {
      id
      user_id
      category_id
      title
      description
      priority
      due_date
      due_time
      completed
      context
      created_at
      updated_at
      category {
        id
        name
        color
      }
    }
  }
''';

/// Query para buscar uma tarefa específica por ID.
const String getTaskByIdQuery = r'''
  query GetTaskById($id: uuid!) {
    tasks_by_pk(id: $id) {
      id
      user_id
      category_id
      title
      description
      priority
      due_date
      due_time
      completed
      context
      created_at
      updated_at
      category {
        id
        name
        color
      }
    }
  }
''';

/// Query para buscar tarefas por categoria.
const String getTasksByCategoryQuery = r'''
  query GetTasksByCategory($userId: uuid!, $categoryId: uuid!) {
    tasks(
      where: {
        user_id: { _eq: $userId },
        category_id: { _eq: $categoryId }
      }
      order_by: [
        { completed: asc },
        { priority: desc },
        { due_date: asc_nulls_last }
      ]
    ) {
      id
      user_id
      category_id
      title
      description
      priority
      due_date
      due_time
      completed
      context
      created_at
      updated_at
      category {
        id
        name
        color
      }
    }
  }
''';

/// Query para buscar tarefas pendentes (não concluídas).
const String getPendingTasksQuery = r'''
  query GetPendingTasks($userId: uuid!) {
    tasks(
      where: {
        user_id: { _eq: $userId },
        completed: { _eq: false }
      }
      order_by: [
        { priority: desc },
        { due_date: asc_nulls_last }
      ]
    ) {
      id
      user_id
      category_id
      title
      description
      priority
      due_date
      due_time
      completed
      context
      created_at
      updated_at
      category {
        id
        name
        color
      }
    }
  }
''';

/// Query para buscar tarefas de hoje.
const String getTodayTasksQuery = r'''
  query GetTodayTasks($userId: uuid!, $today: date!) {
    tasks(
      where: {
        user_id: { _eq: $userId },
        due_date: { _eq: $today }
      }
      order_by: [
        { completed: asc },
        { priority: desc },
        { due_time: asc_nulls_last }
      ]
    ) {
      id
      user_id
      category_id
      title
      description
      priority
      due_date
      due_time
      completed
      context
      created_at
      updated_at
      category {
        id
        name
        color
      }
    }
  }
''';

/// Query para buscar tarefas atrasadas.
const String getOverdueTasksQuery = r'''
  query GetOverdueTasks($userId: uuid!, $today: date!) {
    tasks(
      where: {
        user_id: { _eq: $userId },
        completed: { _eq: false },
        due_date: { _lt: $today }
      }
      order_by: [
        { priority: desc },
        { due_date: asc }
      ]
    ) {
      id
      user_id
      category_id
      title
      description
      priority
      due_date
      due_time
      completed
      context
      created_at
      updated_at
      category {
        id
        name
        color
      }
    }
  }
''';

/// Query para buscar tarefas por contexto.
const String getTasksByContextQuery = r'''
  query GetTasksByContext($userId: uuid!, $context: String!) {
    tasks(
      where: {
        user_id: { _eq: $userId },
        context: { _eq: $context },
        completed: { _eq: false }
      }
      order_by: [
        { priority: desc },
        { due_date: asc_nulls_last }
      ]
    ) {
      id
      user_id
      category_id
      title
      description
      priority
      due_date
      due_time
      completed
      context
      created_at
      updated_at
      category {
        id
        name
        color
      }
    }
  }
''';

/// Query para contar tarefas por status.
const String getTaskCountsQuery = r'''
  query GetTaskCounts($userId: uuid!, $today: date!) {
    total: tasks_aggregate(where: { user_id: { _eq: $userId } }) {
      aggregate {
        count
      }
    }
    pending: tasks_aggregate(
      where: { 
        user_id: { _eq: $userId }, 
        completed: { _eq: false } 
      }
    ) {
      aggregate {
        count
      }
    }
    completed: tasks_aggregate(
      where: { 
        user_id: { _eq: $userId }, 
        completed: { _eq: true } 
      }
    ) {
      aggregate {
        count
      }
    }
    overdue: tasks_aggregate(
      where: { 
        user_id: { _eq: $userId }, 
        completed: { _eq: false },
        due_date: { _lt: $today }
      }
    ) {
      aggregate {
        count
      }
    }
    today: tasks_aggregate(
      where: { 
        user_id: { _eq: $userId }, 
        due_date: { _eq: $today }
      }
    ) {
      aggregate {
        count
      }
    }
  }
''';

