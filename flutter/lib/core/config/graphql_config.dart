/// Configuração do cliente GraphQL para conexão com Hasura.
///
/// Este arquivo configura o cliente GraphQL com suporte a:
/// - Queries e Mutations via HTTP
/// - Subscriptions via WebSocket
/// - Cache em memória
library;

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'app_config.dart';

/// Classe responsável por configurar e fornecer o cliente GraphQL.
///
/// Implementa o padrão Singleton para garantir uma única instância
/// do cliente em toda a aplicação.
class GraphQLConfig {
  /// Instância singleton da configuração GraphQL.
  static final GraphQLConfig _instance = GraphQLConfig._internal();

  /// Construtor factory que retorna a instância singleton.
  factory GraphQLConfig() => _instance;

  /// Construtor privado para o padrão Singleton.
  GraphQLConfig._internal();

  /// Cliente GraphQL configurado.
  GraphQLClient? _client;

  /// Link HTTP para queries e mutations.
  ///
  /// Reason: Utilizamos HttpLink com headers de autenticação
  /// para todas as operações que não requerem tempo real.
  HttpLink get _httpLink => HttpLink(
        AppConfig.hasuraEndpoint,
        defaultHeaders: AppConfig.hasuraHeaders,
      );

  /// Link WebSocket para subscriptions em tempo real.
  ///
  /// Reason: O WebSocket mantém uma conexão persistente com o servidor,
  /// permitindo que o Hasura envie atualizações em tempo real.
  WebSocketLink get _webSocketLink => WebSocketLink(
        AppConfig.hasuraWebSocketEndpoint,
        config: SocketClientConfig(
          autoReconnect: true,
          inactivityTimeout: const Duration(seconds: 30),
          initialPayload: () => {
            'headers': AppConfig.hasuraHeaders,
          },
        ),
        subProtocol: GraphQLProtocol.graphqlTransportWs,
      );

  /// Link combinado que roteia operações para HTTP ou WebSocket.
  ///
  /// Reason: Subscriptions precisam de WebSocket, enquanto queries
  /// e mutations funcionam melhor via HTTP por serem operações únicas.
  Link get _link => Link.split(
        (request) => request.isSubscription,
        _webSocketLink,
        _httpLink,
      );

  /// Retorna o cliente GraphQL configurado.
  ///
  /// Se o cliente ainda não foi inicializado, cria uma nova instância
  /// com cache em memória.
  GraphQLClient get client {
    _client ??= GraphQLClient(
      link: _link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
    return _client!;
  }

  /// Retorna um ValueNotifier do cliente para uso com GraphQLProvider.
  ///
  /// Returns:
  ///   ValueNotifier contendo o cliente GraphQL configurado.
  ValueNotifier<GraphQLClient> get clientNotifier =>
      ValueNotifier<GraphQLClient>(client);

  /// Limpa o cache do cliente GraphQL.
  ///
  /// Útil para invalidar dados após logout ou quando necessário
  /// forçar uma nova busca de dados.
  void clearCache() {
    _client?.cache.store.reset();
  }

  /// Reconstrói o cliente GraphQL.
  ///
  /// Útil quando as configurações de autenticação mudam
  /// (ex: após login/logout).
  void resetClient() {
    _client = null;
  }
}

