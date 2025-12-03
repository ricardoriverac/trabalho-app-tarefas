/// Widget principal do aplicativo com configuração de tema e rotas.
///
/// Este arquivo define a aparência e navegação do app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'themes/app_theme.dart';

/// Widget do Material App com configurações de tema.
class TaskListApp extends ConsumerWidget {
  /// Construtor padrão.
  const TaskListApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Configuração de localização para português brasileiro
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _buildHome(authState),
    );
  }

  /// Constrói a tela inicial baseada no estado de autenticação.
  Widget _buildHome(AuthState authState) {
    return switch (authState) {
      AuthInitial() => const _SplashScreen(),
      AuthLoading() => const _SplashScreen(),
      AuthAuthenticated() => const HomeScreen(),
      AuthUnauthenticated() => const LoginScreen(),
      AuthError() => const LoginScreen(),
    };
  }
}

/// Tela de splash durante carregamento inicial.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              AppConfig.appName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
