# 📝 Lista de Tarefas - Smart Task List

## 🎯 Tarefa Atual

**Fase 6: Dashboard e Estatísticas** ✅ CONCLUÍDA

## ✅ Tarefas Concluídas

### Fase 1 - Configuração Base

- [x] Criar projeto Flutter inicial
- [x] Criar PLANNING.md
- [x] Criar TASK.md
- [x] Adicionar dependências no pubspec.yaml
- [x] Criar estrutura de pastas (core, data, presentation)
- [x] Configurar cliente GraphQL (HTTP + WebSocket)
- [x] Criar modelos de dados
- [x] Criar queries, mutations e subscriptions GraphQL
- [x] Criar repositórios (TaskRepository, CategoryRepository, UserRepository)
- [x] Criar tema do aplicativo (claro e escuro)
- [x] Criar telas e widgets iniciais

### Fase 2 - Funcionalidades Básicas

- [x] Criar usuário de teste no Hasura
- [x] Implementar autenticação simples (AuthService + SharedPreferences)
- [x] Criar providers Riverpod (AuthProvider, TaskProvider, CategoryProvider)
- [x] Criar tela de login (LoginScreen)
- [x] Implementar filtros (status, prioridade, categoria)
- [x] Implementar ordenação (prioridade, data, título, criação)
- [x] Criar barra de filtros (FilterBar)

### Fase 3 - Categorias

- [x] Criar tela de listagem de categorias (CategoriesScreen)
- [x] Criar formulário de categoria (CategoryFormScreen)
- [x] Criar widget de seleção de cor (ColorPicker)
- [x] Criar menu lateral (AppDrawer)
- [x] Integrar Drawer na HomeScreen

### Fase 4 - Prioridades e Datas

- [x] Criar serviço de notificações locais (NotificationService)
- [x] Criar tela de agenda (AgendaScreen)
- [x] Criar widget de resumo diário (DailySummary, CompactDailySummary)
- [x] Implementar agendamento de lembretes no formulário de tarefa
- [x] Adicionar navegação para agenda no Drawer
- [x] Integrar resumo compacto na HomeScreen

## 📋 Tarefas Pendentes

### Fase 5 - Funcionalidades Inteligentes

- [ ] Sugestão automática de prioridade
- [ ] Tarefas recorrentes
- [ ] Assistente de criação rápida (parser de texto)
- [ ] Resumo diário ao abrir o app

### Fase 6 - Dashboard e Estatísticas

- [x] Criar tela de dashboard
- [x] Implementar gráficos de produtividade
- [x] Adicionar streak de conclusão
- [ ] Histórico de tarefas

## 🔍 Descobertas Durante o Trabalho

- Flutter 3.38.3 usa CardThemeData em vez de CardTheme
- Hasura requer header x-hasura-admin-secret para autenticação
- WebSocket usa protocolo graphql-transport-ws para subscriptions
- DropdownButtonFormField `value` foi deprecado, usar DropdownMenu
- zonedSchedule requer `uiLocalNotificationDateInterpretation`

---

## 📊 Progresso

| Fase                             | Status       | Progresso |
| -------------------------------- | ------------ | --------- |
| Fase 1 - Base                    | ✅ Concluída | 100%      |
| Fase 2 - Funcionalidades Básicas | ✅ Concluída | 100%      |
| Fase 3 - Categorias              | ✅ Concluída | 100%      |
| Fase 4 - Prioridades/Datas       | ✅ Concluída | 100%      |
| Fase 5 - Inteligência            | ⏸️ Pulada    | 0%        |
| Fase 6 - Dashboard               | ✅ Concluída | 75%       |

## 📁 Estrutura de Arquivos Atualizada

```
lib/
├── main.dart                           # Ponto de entrada (inicializa notificações)
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   └── graphql_config.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── services/
│       ├── auth_service.dart
│       └── notification_service.dart   # Serviço de notificações
├── data/
│   ├── models/
│   ├── graphql/
│   └── repositories/
└── presentation/
    ├── app.dart
    ├── providers/
    │   ├── auth_provider.dart
    │   ├── task_provider.dart
    │   ├── category_provider.dart
    │   └── stats_provider.dart         # 🆕 Provider de estatísticas
    ├── themes/
    │   └── app_theme.dart
    ├── screens/
    │   ├── agenda/
    │   │   └── agenda_screen.dart      # Visualização por data
    │   ├── auth/
    │   │   └── login_screen.dart
    │   ├── category/
    │   │   ├── categories_screen.dart
    │   │   └── category_form_screen.dart
    │   ├── dashboard/                  # 🆕 Pasta do dashboard
    │   │   └── dashboard_screen.dart   # Tela de estatísticas
    │   ├── home/
    │   │   └── home_screen.dart
    │   └── task/
    │       └── task_form_screen.dart
    └── widgets/
        ├── app_drawer.dart             # Atualizado com dashboard
        ├── charts/                     # 🆕 Pasta de gráficos
        │   ├── bar_chart_widget.dart   # Gráfico de barras
        │   ├── progress_ring_widget.dart # Anel de progresso
        │   └── stat_card_widget.dart   # Cards de estatísticas
        ├── color_picker.dart
        ├── daily_summary.dart
        ├── filter_bar.dart
        └── task_card.dart
```
