/// Modelo de dados para representar a recorrência de uma tarefa.
///
/// Este modelo corresponde à tabela `task_recurrence` no banco de dados Hasura.
library;

import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// Representa a configuração de recorrência de uma tarefa.
///
/// Permite criar tarefas que se repetem automaticamente com base
/// em diferentes frequências (diária, semanal, mensal, etc.).
class TaskRecurrenceModel extends Equatable {
  /// Identificador único da recorrência (UUID).
  final String id;

  /// ID da tarefa associada.
  final String taskId;

  /// Frequência da recorrência (daily, weekly, monthly, every_x_days).
  final String frequency;

  /// Valor do intervalo (ex: 3 para "a cada 3 dias").
  ///
  /// Reason: Utilizado quando frequency é 'every_x_days'
  /// para definir o intervalo personalizado.
  final int? intervalValue;

  /// Data da próxima ocorrência.
  final DateTime? nextOccurrence;

  /// Data e hora de criação do registro.
  final DateTime? createdAt;

  /// Construtor principal.
  const TaskRecurrenceModel({
    required this.id,
    required this.taskId,
    required this.frequency,
    this.intervalValue,
    this.nextOccurrence,
    this.createdAt,
  });

  /// Cria uma instância de [TaskRecurrenceModel] a partir de um Map JSON.
  factory TaskRecurrenceModel.fromJson(Map<String, dynamic> json) {
    return TaskRecurrenceModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      frequency: json['frequency'] as String,
      intervalValue: json['interval_value'] as int?,
      nextOccurrence: json['next_occurrence'] != null
          ? DateTime.parse(json['next_occurrence'] as String)
          : null,
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
      'frequency': frequency,
      'interval_value': intervalValue,
      'next_occurrence': nextOccurrence?.toIso8601String().split('T').first,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Retorna o label traduzido da frequência.
  String get frequencyLabel => RecurrenceFrequency.getLabel(frequency);

  /// Calcula a próxima data de ocorrência baseada na frequência.
  ///
  /// Args:
  ///   fromDate: Data base para o cálculo (padrão: data atual).
  ///
  /// Returns:
  ///   Nova data calculada com base na frequência.
  DateTime calculateNextOccurrence({DateTime? fromDate}) {
    final baseDate = fromDate ?? DateTime.now();

    switch (frequency) {
      case RecurrenceFrequency.daily:
        return baseDate.add(const Duration(days: 1));

      case RecurrenceFrequency.weekly:
        return baseDate.add(const Duration(days: 7));

      case RecurrenceFrequency.monthly:
        // Reason: Adicionar um mês considerando variação de dias
        return DateTime(
          baseDate.year,
          baseDate.month + 1,
          baseDate.day,
        );

      case RecurrenceFrequency.everyXDays:
        final days = intervalValue ?? 1;
        return baseDate.add(Duration(days: days));

      default:
        return baseDate.add(const Duration(days: 1));
    }
  }

  /// Cria uma cópia do modelo com campos alterados.
  TaskRecurrenceModel copyWith({
    String? id,
    String? taskId,
    String? frequency,
    int? intervalValue,
    DateTime? nextOccurrence,
    DateTime? createdAt,
  }) {
    return TaskRecurrenceModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      frequency: frequency ?? this.frequency,
      intervalValue: intervalValue ?? this.intervalValue,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        frequency,
        intervalValue,
        nextOccurrence,
        createdAt,
      ];

  @override
  String toString() =>
      'TaskRecurrenceModel(id: $id, taskId: $taskId, frequency: $frequency)';
}

