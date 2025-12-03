/// Modelo de dados para representar uma categoria de tarefas.
///
/// Este modelo corresponde à tabela `categories` no banco de dados Hasura.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Representa uma categoria para agrupar tarefas.
///
/// Categorias permitem organizar tarefas por projetos ou áreas
/// (ex: Trabalho, Casa, Estudos).
class CategoryModel extends Equatable {
  /// Identificador único da categoria (UUID).
  final String id;

  /// ID do usuário proprietário da categoria.
  final String userId;

  /// Nome da categoria.
  final String name;

  /// Cor da categoria em formato hexadecimal (ex: #FF5733).
  final String? color;

  /// Data e hora de criação do registro.
  final DateTime? createdAt;

  /// Construtor principal.
  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    this.color,
    this.createdAt,
  });

  /// Cria uma instância de [CategoryModel] a partir de um Map JSON.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Reason: Tratamos cada campo de forma segura para evitar erros de cast.
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Converte a instância para um Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Retorna a cor como objeto [Color] do Flutter.
  ///
  /// Returns:
  ///   Objeto Color correspondente ao valor hexadecimal,
  ///   ou cinza como padrão se não houver cor definida.
  Color get colorValue {
    if (color == null || color!.isEmpty) {
      return Colors.grey;
    }

    try {
      // Remove o # se presente e converte para int
      final hexColor = color!.replaceFirst('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Cria uma cópia do modelo com campos alterados.
  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, color, createdAt];

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, color: $color)';
}
