/// Testes de widgets do aplicativo Smart Task List.
///
/// Este arquivo contém os testes básicos de widgets para garantir
/// que a aplicação funciona corretamente.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Constrói o app envolvido por ProviderScope (necessário para Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartTaskListApp(),
      ),
    );

    // Verifica se o app foi construído
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Splash screen should show app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartTaskListApp(),
      ),
    );

    // Verifica se o nome do app está presente na splash
    expect(find.text('Smart Task List'), findsOneWidget);
  });
}
