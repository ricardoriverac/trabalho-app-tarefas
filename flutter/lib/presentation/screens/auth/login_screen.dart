/// Tela de login do aplicativo.
///
/// Permite que o usuário faça login com email ou crie uma nova conta.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../themes/app_theme.dart';

/// Tela de login/registro simplificada.
///
/// Reason: Para um MVP/trabalho de faculdade, usamos autenticação
/// simples por email sem senha. Em produção, usar auth provider real.
class LoginScreen extends ConsumerStatefulWidget {
  /// Construtor padrão.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Chave do formulário.
  final _formKey = GlobalKey<FormState>();

  /// Controlador do campo de email.
  final _emailController = TextEditingController();

  /// Controlador do campo de nome (para registro).
  final _nameController = TextEditingController();

  /// Indica se está no modo de registro.
  bool _isRegisterMode = false;

  /// ID do usuário de teste para login rápido.
  static const String _testUserId = '00000000-0000-0000-0000-000000000001';

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Faz login ou registro.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);

    if (_isRegisterMode) {
      await authNotifier.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
    } else {
      await authNotifier.loginWithEmail(_emailController.text.trim());
    }
  }

  /// Login rápido com usuário de teste.
  Future<void> _loginWithTestUser() async {
    await ref.read(authProvider.notifier).loginWithId(_testUserId);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    // Mostra erro se houver
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Ícone
                _buildHeader(context),
                const SizedBox(height: 48),

                // Formulário
                _buildForm(context, isLoading),
                const SizedBox(height: 24),

                // Alternar entre login e registro
                _buildModeToggle(context),
                const SizedBox(height: 32),

                // Divisor
                _buildDivider(context),
                const SizedBox(height: 24),

                // Login rápido (desenvolvimento)
                _buildQuickLogin(context, isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o cabeçalho com ícone e título.
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Smart Task List',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _isRegisterMode
              ? 'Crie sua conta para começar'
              : 'Entre para gerenciar suas tarefas',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  /// Constrói o formulário de login/registro.
  Widget _buildForm(BuildContext context, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de nome (apenas no registro)
          if (_isRegisterMode) ...[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Seu nome completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              enabled: !isLoading,
              validator: (value) {
                if (_isRegisterMode &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Por favor, informe seu nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],

          // Campo de email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'seu@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, informe seu email';
              }
              if (!value.contains('@')) {
                return 'Por favor, informe um email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Botão de submit
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isRegisterMode ? 'Criar Conta' : 'Entrar'),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o botão para alternar entre login e registro.
  Widget _buildModeToggle(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          _isRegisterMode = !_isRegisterMode;
        });
      },
      child: Text(
        _isRegisterMode
            ? 'Já tem uma conta? Entre aqui'
            : 'Não tem conta? Cadastre-se',
      ),
    );
  }

  /// Constrói o divisor.
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  /// Constrói o botão de login rápido para desenvolvimento.
  Widget _buildQuickLogin(BuildContext context, bool isLoading) {
    return Column(
      children: [
        Text(
          'Acesso rápido (desenvolvimento)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isLoading ? null : _loginWithTestUser,
          icon: const Icon(Icons.bug_report),
          label: const Text('Entrar com usuário de teste'),
        ),
      ],
    );
  }
}

