/// Constantes globais do aplicativo Smart Task List.
///
/// Este arquivo centraliza todas as constantes utilizadas
/// em diferentes partes do aplicativo.
library;

/// Constantes relacionadas às tarefas.
abstract class TaskConstants {
  /// Número máximo de tarefas por página na listagem.
  static const int maxTasksPerPage = 20;

  /// Tempo limite para considerar uma tarefa como atrasada (em dias).
  static const int overdueDaysThreshold = 1;

  /// Duração padrão de uma sessão Pomodoro (em minutos).
  static const int defaultPomodoroDuration = 25;

  /// Duração padrão de uma pausa curta (em minutos).
  static const int defaultShortBreak = 5;

  /// Duração padrão de uma pausa longa (em minutos).
  static const int defaultLongBreak = 15;
}

/// Constantes de prioridade das tarefas.
///
/// Reason: Mapeamos os valores do ENUM do PostgreSQL para constantes
/// que podem ser facilmente utilizadas no frontend.
abstract class TaskPriority {
  /// Prioridade baixa.
  static const String low = 'low';

  /// Prioridade média.
  static const String medium = 'medium';

  /// Prioridade alta.
  static const String high = 'high';

  /// Lista de todas as prioridades disponíveis.
  static const List<String> all = [low, medium, high];

  /// Retorna o label traduzido para exibição.
  static String getLabel(String priority) {
    switch (priority) {
      case low:
        return 'Baixa';
      case medium:
        return 'Média';
      case high:
        return 'Alta';
      default:
        return 'Desconhecida';
    }
  }

  /// Retorna o valor numérico para ordenação.
  ///
  /// Reason: Valores maiores indicam maior prioridade,
  /// facilitando a ordenação decrescente.
  static int getWeight(String priority) {
    switch (priority) {
      case high:
        return 3;
      case medium:
        return 2;
      case low:
        return 1;
      default:
        return 0;
    }
  }
}

/// Constantes de frequência de recorrência.
abstract class RecurrenceFrequency {
  /// Diariamente.
  static const String daily = 'daily';

  /// Semanalmente.
  static const String weekly = 'weekly';

  /// Mensalmente.
  static const String monthly = 'monthly';

  /// A cada X dias.
  static const String everyXDays = 'every_x_days';

  /// Lista de todas as frequências disponíveis.
  static const List<String> all = [daily, weekly, monthly, everyXDays];

  /// Retorna o label traduzido para exibição.
  static String getLabel(String frequency) {
    switch (frequency) {
      case daily:
        return 'Diariamente';
      case weekly:
        return 'Semanalmente';
      case monthly:
        return 'Mensalmente';
      case everyXDays:
        return 'A cada X dias';
      default:
        return 'Desconhecida';
    }
  }
}

/// Constantes de contexto das tarefas.
abstract class TaskContext {
  /// Contexto: casa.
  static const String home = 'casa';

  /// Contexto: trabalho.
  static const String work = 'trabalho';

  /// Contexto: rua/externo.
  static const String outside = 'rua';

  /// Contexto: computador.
  static const String computer = 'computador';

  /// Contexto: telefone.
  static const String phone = 'telefone';

  /// Lista de todos os contextos disponíveis.
  static const List<String> all = [home, work, outside, computer, phone];
}

/// Constantes de duração de animações.
abstract class AnimationDuration {
  /// Animação rápida.
  static const Duration fast = Duration(milliseconds: 150);

  /// Animação normal.
  static const Duration normal = Duration(milliseconds: 300);

  /// Animação lenta.
  static const Duration slow = Duration(milliseconds: 500);
}
