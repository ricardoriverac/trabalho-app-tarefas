/// Mutations GraphQL para operações de escrita de tarefas.
///
/// Este arquivo contém todas as mutations relacionadas à entidade Task.
library;

/// Mutation para criar uma nova tarefa.
const String createTaskMutation = r'''
  mutation CreateTask($task: tasks_insert_input!) {
    insert_tasks_one(object: $task) {
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

/// Mutation para atualizar uma tarefa existente.
const String updateTaskMutation = r'''
  mutation UpdateTask($id: uuid!, $changes: tasks_set_input!) {
    update_tasks_by_pk(pk_columns: { id: $id }, _set: $changes) {
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

/// Mutation para deletar uma tarefa.
const String deleteTaskMutation = r'''
  mutation DeleteTask($id: uuid!) {
    delete_tasks_by_pk(id: $id) {
      id
    }
  }
''';

/// Mutation para marcar tarefa como concluída.
const String toggleTaskCompletionMutation = r'''
  mutation ToggleTaskCompletion($id: uuid!, $completed: Boolean!) {
    update_tasks_by_pk(
      pk_columns: { id: $id }, 
      _set: { completed: $completed }
    ) {
      id
      completed
      updated_at
    }
  }
''';

/// Mutation para atualizar a prioridade de uma tarefa.
const String updateTaskPriorityMutation = r'''
  mutation UpdateTaskPriority($id: uuid!, $priority: task_priority!) {
    update_tasks_by_pk(
      pk_columns: { id: $id }, 
      _set: { priority: $priority }
    ) {
      id
      priority
      updated_at
    }
  }
''';

/// Mutation para atualizar a categoria de uma tarefa.
const String updateTaskCategoryMutation = r'''
  mutation UpdateTaskCategory($id: uuid!, $categoryId: uuid) {
    update_tasks_by_pk(
      pk_columns: { id: $id }, 
      _set: { category_id: $categoryId }
    ) {
      id
      category_id
      updated_at
      category {
        id
        name
        color
      }
    }
  }
''';

/// Mutation para atualizar a data limite de uma tarefa.
const String updateTaskDueDateMutation = r'''
  mutation UpdateTaskDueDate($id: uuid!, $dueDate: date, $dueTime: time) {
    update_tasks_by_pk(
      pk_columns: { id: $id }, 
      _set: { due_date: $dueDate, due_time: $dueTime }
    ) {
      id
      due_date
      due_time
      updated_at
    }
  }
''';

/// Mutation para criar múltiplas tarefas de uma vez.
///
/// Reason: Útil para importação em massa ou criação de tarefas
/// a partir de templates/checklists.
const String createMultipleTasksMutation = r'''
  mutation CreateMultipleTasks($tasks: [tasks_insert_input!]!) {
    insert_tasks(objects: $tasks) {
      returning {
        id
        title
        created_at
      }
      affected_rows
    }
  }
''';

/// Mutation para deletar todas as tarefas concluídas.
const String deleteCompletedTasksMutation = r'''
  mutation DeleteCompletedTasks($userId: uuid!) {
    delete_tasks(
      where: { 
        user_id: { _eq: $userId }, 
        completed: { _eq: true } 
      }
    ) {
      affected_rows
    }
  }
''';

