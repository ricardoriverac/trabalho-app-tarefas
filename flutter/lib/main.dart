/// Ponto de entrada do aplicativo Smart Task List.
///
/// Este arquivo configura o app com GraphQL Provider, Riverpod e tema inicial.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/graphql_config.dart';
import 'core/services/notification_service.dart';
import 'presentation/app.dart';

/// Função principal que inicializa o aplicativo.
///
/// Configura o cache do Hive para GraphQL, notificações e inicializa o app.
void main() async {
  // Garante que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Hive para cache do GraphQL
  await initHiveForFlutter();

  // Inicializa formatação de datas em português
  await initializeDateFormatting('pt_BR', null);

  // Inicializa o serviço de notificações
  await NotificationService().initialize();

  // Executa o aplicativo envolvido por ProviderScope (Riverpod)
  runApp(
    const ProviderScope(
      child: SmartTaskListApp(),
    ),
  );
}

/// Widget raiz do aplicativo.
///
/// Configura o GraphQL Provider para toda a árvore de widgets.
class SmartTaskListApp extends StatelessWidget {
  /// Construtor padrão.
  const SmartTaskListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig().clientNotifier,
      child: const TaskListApp(),
    );
  }
}
