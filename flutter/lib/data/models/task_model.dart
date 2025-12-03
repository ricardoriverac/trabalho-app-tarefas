/// Modelo de dados para representar uma tarefa.
///
/// Este modelo corresponde à tabela `tasks` no banco de dados Hasura.
library;

import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';
import 'category_model.dart';

/// Representa uma tarefa no sistema.
///
/// Contém todas as informações necessárias para gerenciar uma tarefa,
/// incluindo prioridade, datas, contexto e relacionamentos.
class TaskModel extends Equatable {
  /// Identificador único da tarefa (UUID).
  final String id;

  /// ID do usuário proprietário da tarefa.
  final String userId;

  /// ID da categoria associada (opcional).
  final String? categoryId;

  /// Título da tarefa.
  final String title;

  /// Descrição detalhada da tarefa (opcional).
  final String? description;

  /// Prioridade da tarefa (low, medium, high).
  final String priority;

  /// Data limite para conclusão (opcional).
  final DateTime? dueDate;

  /// Hora limite para conclusão (opcional).
  ///
  /// Reason: Armazenamos como String pois o PostgreSQL retorna TIME
  /// em formato "HH:MM:SS" e nem todas as tarefas têm hora definida.
  final String? dueTime;

  /// Indica se a tarefa foi concluída.
  final bool completed;

  /// Contexto da tarefa (casa, trabalho, rua, etc.).
  final String? context;

  /// Data e hora de criação do registro.
  final DateTime? createdAt;

  /// Data e hora da última atualização.
  final DateTime? updatedAt;

  /// Categoria associada (quando carregada via join).
  final CategoryModel? category;

  /// Construtor principal.
  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.categoryId,
    this.description,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.dueTime,
    this.completed = false,
    this.context,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  /// Cria uma instância de [TaskModel] a partir de um Map JSON.
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Reason: O Hasura pode retornar campos como null ou com tipos diferentes
    // dependendo do estado do banco. Tratamos cada campo de forma segura.
    return TaskModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      priority: json['priority']?.toString() ?? TaskPriority.medium,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      dueTime: json['due_time']?.toString(),
      completed: json['completed'] == true,
      context: json['context']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converte a instância para um Map JSON.
  ///
  /// Args:
  ///   includeId: Se true, inclui o ID no JSON (para updates).
  Map<String, dynamic> toJson({bool includeId = true}) {
    final Map<String, dynamic> json = {
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'priority': priority,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'due_time': dueTime,
      'completed': completed,
      'context': context,
    };

    if (includeId) {
      json['id'] = id;
    }

    return json;
  }

  /// Verifica se a tarefa está atrasada.
  ///
  /// Returns:
  ///   true se a tarefa não foi concluída e a data limite já passou.
  bool get isOverdue {
    if (completed || dueDate == null) return false;

    final now = DateTime.now();
    final dueDateOnly = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final today = DateTime(now.year, now.month, now.day);

    return dueDateOnly.isBefore(today);
  }

  /// Verifica se a tarefa vence hoje.
  ///
  /// Returns:
  ///   true se a data limite é hoje.
  bool get isDueToday {
    if (dueDate == null) return false;

    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Verifica se a tarefa vence amanhã.
  bool get isDueTomorrow {
    if (dueDate == null) return false;

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }

  /// Retorna o peso da prioridade para ordenação.
  int get priorityWeight => TaskPriority.getWeight(priority);

  /// Retorna o label traduzido da prioridade.
  String get priorityLabel => TaskPriority.getLabel(priority);

  /// Verifica se é uma tarefa de alta prioridade.
  bool get isHighPriority => priority == TaskPriority.high;

  /// Cria uma cópia do modelo com campos alterados.
  TaskModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? dueTime,
    bool? completed,
    String? context,
    DateTime? createdAt,
    DateTime? updatedAt,
    CategoryModel? category,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      completed: completed ?? this.completed,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    title,
    description,
    priority,
    dueDate,
    dueTime,
    completed,
    context,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() =>
      'TaskModel(id: $id, title: $title, completed: $completed)';
}
