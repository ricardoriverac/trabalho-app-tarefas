/// Mutations GraphQL para operações de escrita de usuários.
///
/// Este arquivo contém todas as mutations relacionadas à entidade User.
library;

/// Mutation para criar um novo usuário.
const String createUserMutation = r'''
  mutation CreateUser($user: users_insert_input!) {
    insert_users_one(object: $user) {
      id
      name
      email
      created_at
    }
  }
''';

/// Mutation para atualizar um usuário existente.
const String updateUserMutation = r'''
  mutation UpdateUser($id: uuid!, $changes: users_set_input!) {
    update_users_by_pk(pk_columns: { id: $id }, _set: $changes) {
      id
      name
      email
      created_at
    }
  }
''';

/// Mutation para criar usuário se não existir (upsert por email).
///
/// Reason: Útil para login/registro onde queremos criar o usuário
/// apenas se ele ainda não existir no sistema.
const String upsertUserMutation = r'''
  mutation UpsertUser($user: users_insert_input!) {
    insert_users_one(
      object: $user,
      on_conflict: {
        constraint: users_email_key,
        update_columns: [name]
      }
    ) {
      id
      name
      email
      created_at
    }
  }
''';

