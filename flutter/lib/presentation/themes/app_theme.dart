/// Definição dos temas do aplicativo Smart Task List.
///
/// Este arquivo contém os temas claro e escuro do app,
/// seguindo as diretrizes do Material Design 3.
library;

import 'package:flutter/material.dart';

/// Classe que define os temas do aplicativo.
///
/// Fornece temas claro e escuro com cores personalizadas
/// e estilos consistentes para toda a aplicação.
abstract class AppTheme {
  // ===================================
  // CORES PRINCIPAIS
  // ===================================

  /// Cor primária do app (azul vibrante).
  static const Color primaryColor = Color(0xFF2563EB);

  /// Cor secundária (verde para sucesso/conclusão).
  static const Color successColor = Color(0xFF10B981);

  /// Cor de alerta/atenção (amarelo).
  static const Color warningColor = Color(0xFFF59E0B);

  /// Cor de erro/perigo (vermelho).
  static const Color errorColor = Color(0xFFEF4444);

  /// Cor de prioridade alta.
  static const Color highPriorityColor = Color(0xFFDC2626);

  /// Cor de prioridade média.
  static const Color mediumPriorityColor = Color(0xFFF59E0B);

  /// Cor de prioridade baixa.
  static const Color lowPriorityColor = Color(0xFF3B82F6);

  // ===================================
  // TEMA CLARO
  // ===================================

  /// Tema claro do aplicativo.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
      ),
      // Chips
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Dividers
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  // ===================================
  // TEMA ESCURO
  // ===================================

  /// Tema escuro do aplicativo.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade800,
          ),
        ),
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
      ),
      // Chips
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Dividers
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 1,
      ),
    );
  }

  // ===================================
  // MÉTODOS AUXILIARES
  // ===================================

  /// Retorna a cor correspondente à prioridade.
  ///
  /// Args:
  ///   priority: String da prioridade (low, medium, high).
  ///
  /// Returns:
  ///   Color correspondente à prioridade.
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return highPriorityColor;
      case 'medium':
        return mediumPriorityColor;
      case 'low':
        return lowPriorityColor;
      default:
        return Colors.grey;
    }
  }

  /// Retorna o ícone correspondente à prioridade.
  ///
  /// Args:
  ///   priority: String da prioridade (low, medium, high).
  ///
  /// Returns:
  ///   IconData correspondente à prioridade.
  static IconData getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.keyboard_double_arrow_up;
      case 'medium':
        return Icons.drag_handle;
      case 'low':
        return Icons.keyboard_double_arrow_down;
      default:
        return Icons.remove;
    }
  }
}

