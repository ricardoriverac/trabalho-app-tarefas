/// Modelo de dados para representar o histórico de uma tarefa.
///
/// Este modelo corresponde à tabela `task_history` no banco de dados Hasura.
library;

import 'package:equatable/equatable.dart';

/// Representa um registro histórico de conclusão de tarefa.
///
/// Armazena informações sobre quando a tarefa foi concluída,
/// quanto tempo levou e uma pontuação de produtividade opcional.
class TaskHistoryModel extends Equatable {
  /// Identificador único do registro (UUID).
  final String id;

  /// ID da tarefa associada.
  final String taskId;

  /// Data e hora em que a tarefa foi concluída.
  final DateTime? completedAt;

  /// Duração em minutos que levou para completar a tarefa.
  ///
  /// Reason: Útil para o modo Pomodoro e para calcular
  /// estatísticas de produtividade do usuário.
  final int? durationMinutes;

  /// Pontuação de produtividade (0-100).
  ///
  /// Reason: Campo opcional para gamificação e análise
  /// de desempenho do usuário ao longo do tempo.
  final int? productivityScore;

  /// Data e hora de criação do registro.
  final DateTime? createdAt;

  /// Construtor principal.
  const TaskHistoryModel({
    required this.id,
    required this.taskId,
    this.completedAt,
    this.durationMinutes,
    this.productivityScore,
    this.createdAt,
  });

  /// Cria uma instância de [TaskHistoryModel] a partir de um Map JSON.
  factory TaskHistoryModel.fromJson(Map<String, dynamic> json) {
    return TaskHistoryModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int?,
      productivityScore: json['productivity_score'] as int?,
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
      'completed_at': completedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'productivity_score': productivityScore,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Retorna a duração formatada como string legível.
  ///
  /// Returns:
  ///   String no formato "Xh Ym" ou "Xm" dependendo da duração.
  String get formattedDuration {
    if (durationMinutes == null) return '-';

    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Retorna uma descrição textual da pontuação de produtividade.
  String get productivityLabel {
    if (productivityScore == null) return 'Não avaliado';

    if (productivityScore! >= 80) return 'Excelente';
    if (productivityScore! >= 60) return 'Bom';
    if (productivityScore! >= 40) return 'Regular';
    return 'Precisa melhorar';
  }

  /// Cria uma cópia do modelo com campos alterados.
  TaskHistoryModel copyWith({
    String? id,
    String? taskId,
    DateTime? completedAt,
    int? durationMinutes,
    int? productivityScore,
    DateTime? createdAt,
  }) {
    return TaskHistoryModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      productivityScore: productivityScore ?? this.productivityScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        completedAt,
        durationMinutes,
        productivityScore,
        createdAt,
      ];

  @override
  String toString() =>
      'TaskHistoryModel(id: $id, taskId: $taskId, completedAt: $completedAt)';
}

