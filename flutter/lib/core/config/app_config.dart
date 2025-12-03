/// Configurações globais do aplicativo Smart Task List.
///
/// Este arquivo contém todas as constantes de configuração necessárias
/// para conectar ao backend Hasura e outras configurações do app.
library;

/// Classe responsável por armazenar as configurações do aplicativo.
///
/// Utiliza o padrão de constantes para garantir que os valores
/// não sejam modificados em tempo de execução.
abstract class AppConfig {
  /// URL do endpoint GraphQL do Hasura.
  static const String hasuraEndpoint =
      'https://flutter-rest-project.hasura.app/v1/graphql';

  /// URL do endpoint de WebSocket para subscriptions.
  ///
  /// Reason: O Hasura usa wss:// para conexões WebSocket em tempo real,
  /// necessário para as subscriptions GraphQL.
  static const String hasuraWebSocketEndpoint =
      'wss://flutter-rest-project.hasura.app/v1/graphql';

  /// Chave de administrador do Hasura.
  ///
  /// ⚠️ ATENÇÃO: Em produção, esta chave deve ser armazenada de forma segura
  /// (ex: variáveis de ambiente, secure storage) e NUNCA commitada no Git.
  static const String hasuraAdminSecret =
      '7hqRkX4LrTUmUveBDQLocWT4mQ13MfexrAeRaZwX9RKD3D4e8C3JXm6g5MgOXMVF';

  /// Nome do aplicativo.
  static const String appName = 'Smart Task List';

  /// Versão do aplicativo.
  static const String appVersion = '1.0.0';

  /// Headers padrão para requisições ao Hasura.
  static Map<String, String> get hasuraHeaders => {
        'Content-Type': 'application/json',
        'x-hasura-admin-secret': hasuraAdminSecret,
      };
}

