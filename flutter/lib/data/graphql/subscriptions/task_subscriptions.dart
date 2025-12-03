/// Subscriptions GraphQL para atualizações em tempo real de tarefas.
///
/// Este arquivo contém todas as subscriptions relacionadas à entidade Task.
/// Reason: Subscriptions permitem que o app receba atualizações em tempo real
/// sempre que os dados mudam no servidor, sem necessidade de polling.
library;

/// Subscription para observar todas as tarefas de um usuário em tempo real.
const String tasksSubscription = r'''
  subscription WatchTasks($userId: uuid!) {
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

/// Subscription para observar tarefas pendentes em tempo real.
const String pendingTasksSubscription = r'''
  subscription WatchPendingTasks($userId: uuid!) {
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

/// Subscription para observar uma tarefa específica em tempo real.
const String taskByIdSubscription = r'''
  subscription WatchTaskById($id: uuid!) {
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

/// Subscription para observar contadores de tarefas em tempo real.
const String taskCountsSubscription = r'''
  subscription WatchTaskCounts($userId: uuid!, $today: date!) {
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
    completed_today: tasks_aggregate(
      where: { 
        user_id: { _eq: $userId }, 
        completed: { _eq: true },
        updated_at: { _gte: $today }
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
  }
''';

/// Subscription para observar tarefas de hoje em tempo real.
const String todayTasksSubscription = r'''
  subscription WatchTodayTasks($userId: uuid!, $today: date!) {
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

