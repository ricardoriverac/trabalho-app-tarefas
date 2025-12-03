/// Modelo de dados para representar um anexo de tarefa.
///
/// Este modelo corresponde à tabela `task_attachments` no banco de dados Hasura.
library;

import 'package:equatable/equatable.dart';

/// Representa um anexo (arquivo) associado a uma tarefa.
///
/// Permite que usuários adicionem imagens, PDFs e outros arquivos
/// às suas tarefas.
class TaskAttachmentModel extends Equatable {
  /// Identificador único do anexo (UUID).
  final String id;

  /// ID da tarefa associada.
  final String taskId;

  /// URL do arquivo armazenado.
  final String fileUrl;

  /// Tipo do arquivo (ex: image/png, application/pdf).
  final String? fileType;

  /// Data e hora de criação do registro.
  final DateTime? createdAt;

  /// Construtor principal.
  const TaskAttachmentModel({
    required this.id,
    required this.taskId,
    required this.fileUrl,
    this.fileType,
    this.createdAt,
  });

  /// Cria uma instância de [TaskAttachmentModel] a partir de um Map JSON.
  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String?,
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
      'file_url': fileUrl,
      'file_type': fileType,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Verifica se o anexo é uma imagem.
  bool get isImage {
    if (fileType == null) return false;
    return fileType!.startsWith('image/');
  }

  /// Verifica se o anexo é um PDF.
  bool get isPdf {
    return fileType == 'application/pdf';
  }

  /// Retorna a extensão do arquivo baseada no tipo.
  String get fileExtension {
    if (fileType == null) return '';

    switch (fileType) {
      case 'image/png':
        return 'png';
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      case 'image/gif':
        return 'gif';
      case 'application/pdf':
        return 'pdf';
      default:
        return fileType!.split('/').last;
    }
  }

  /// Cria uma cópia do modelo com campos alterados.
  TaskAttachmentModel copyWith({
    String? id,
    String? taskId,
    String? fileUrl,
    String? fileType,
    DateTime? createdAt,
  }) {
    return TaskAttachmentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, taskId, fileUrl, fileType, createdAt];

  @override
  String toString() =>
      'TaskAttachmentModel(id: $id, taskId: $taskId, fileType: $fileType)';
}

