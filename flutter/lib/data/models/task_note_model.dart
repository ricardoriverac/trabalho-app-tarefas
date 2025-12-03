/// Modelo de dados para representar uma nota/comentário de tarefa.
///
/// Este modelo corresponde à tabela `task_notes` no banco de dados Hasura.
library;

import 'package:equatable/equatable.dart';

/// Representa uma nota ou comentário associado a uma tarefa.
///
/// Permite que usuários adicionem informações extras às tarefas,
/// como observações, lembretes ou detalhes adicionais.
class TaskNoteModel extends Equatable {
  /// Identificador único da nota (UUID).
  final String id;

  /// ID da tarefa associada.
  final String taskId;

  /// ID do usuário que criou a nota.
  final String userId;

  /// Conteúdo textual da nota.
  final String content;

  /// Data e hora de criação do registro.
  final DateTime? createdAt;

  /// Construtor principal.
  const TaskNoteModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    this.createdAt,
  });

  /// Cria uma instância de [TaskNoteModel] a partir de um Map JSON.
  factory TaskNoteModel.fromJson(Map<String, dynamic> json) {
    return TaskNoteModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Converte a instância para um Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia do modelo com campos alterados.
  TaskNoteModel copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? content,
    DateTime? createdAt,
  }) {
    return TaskNoteModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, taskId, userId, content, createdAt];

  @override
  String toString() =>
      'TaskNoteModel(id: $id, taskId: $taskId, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
}

