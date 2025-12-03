/// Modelo de dados para representar um usuário.
///
/// Este modelo corresponde à tabela `users` no banco de dados Hasura.
library;

import 'package:equatable/equatable.dart';

/// Representa um usuário do sistema de tarefas.
///
/// Cada usuário pode ter múltiplas tarefas e categorias associadas.
class UserModel extends Equatable {
  /// Identificador único do usuário (UUID).
  final String id;

  /// Nome do usuário.
  final String? name;

  /// Email do usuário (único no sistema).
  final String? email;

  /// Data e hora de criação do registro.
  final DateTime? createdAt;

  /// Construtor principal.
  const UserModel({required this.id, this.name, this.email, this.createdAt});

  /// Cria uma instância de [UserModel] a partir de um Map JSON.
  ///
  /// Args:
  ///   json: Map contendo os dados do usuário.
  ///
  /// Returns:
  ///   Nova instância de [UserModel].
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Reason: Tratamos cada campo de forma segura para evitar erros de cast.
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Converte a instância para um Map JSON.
  ///
  /// Returns:
  ///   Map contendo os dados do usuário.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia do modelo com campos alterados.
  ///
  /// Reason: Imutabilidade - ao invés de modificar o objeto existente,
  /// criamos uma nova instância com os valores atualizados.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, createdAt];

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
