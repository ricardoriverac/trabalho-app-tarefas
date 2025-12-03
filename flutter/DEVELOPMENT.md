# 📚 Documentação de Desenvolvimento - Smart Task List

## 📋 Índice

1. [Visão Geral do Projeto](#visão-geral-do-projeto)
2. [Arquitetura](#arquitetura)
3. [Stack Tecnológica](#stack-tecnológica)
4. [Estrutura de Pastas](#estrutura-de-pastas)
5. [Fases de Desenvolvimento](#fases-de-desenvolvimento)
6. [Configuração do Backend (Hasura)](#configuração-do-backend-hasura)
7. [Modelos de Dados](#modelos-de-dados)
8. [Gerenciamento de Estado](#gerenciamento-de-estado)
9. [Funcionalidades Implementadas](#funcionalidades-implementadas)
10. [Problemas Resolvidos](#problemas-resolvidos)
11. [Como Executar](#como-executar)

---

## 🎯 Visão Geral do Projeto

O **Smart Task List** é um aplicativo de gerenciamento de tarefas inteligente desenvolvido em Flutter, com backend Hasura GraphQL. O objetivo é criar um sistema que vai além de um simples to-do list, incorporando funcionalidades como:

- CRUD completo de tarefas
- Categorização e filtros avançados
- Notificações locais para lembretes
- Visualização em agenda
- Interface moderna com Material Design 3

---

## 🏗️ Arquitetura

O projeto segue uma arquitetura em camadas inspirada em **Clean Architecture**, adaptada para o contexto Flutter:

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  (Screens, Widgets, Providers, Themes)                  │
├─────────────────────────────────────────────────────────┤
│                       DOMAIN                             │
│  (Regras de negócio, casos de uso)                      │
├─────────────────────────────────────────────────────────┤
│                        DATA                              │
│  (Models, Repositories, GraphQL Queries/Mutations)      │
├─────────────────────────────────────────────────────────┤
│                        CORE                              │
│  (Configurações, Serviços, Constantes)                  │
└─────────────────────────────────────────────────────────┘
```

### Princípios Aplicados

- **Separação de Responsabilidades**: Cada camada tem uma função específica
- **Dependency Injection**: Via Riverpod providers
- **Repository Pattern**: Abstração da fonte de dados
- **Imutabilidade**: Models com `copyWith` para alterações

---

## 🛠️ Stack Tecnológica

| Tecnologia                  | Versão | Finalidade                  |
| --------------------------- | ------ | --------------------------- |
| Flutter                     | 3.38.3 | Framework UI                |
| Dart                        | 3.10.1 | Linguagem                   |
| Hasura                      | Cloud  | Backend GraphQL             |
| PostgreSQL                  | -      | Banco de dados (via Hasura) |
| Riverpod                    | 2.6.1  | Gerenciamento de estado     |
| GraphQL Flutter             | 5.1.2  | Cliente GraphQL             |
| flutter_local_notifications | 17.2.4 | Notificações locais         |

### Dependências Principais

```yaml
dependencies:
  # UI
  flutter_localizations  # Suporte a português brasileiro
  cupertino_icons

  # GraphQL
  graphql_flutter        # Cliente GraphQL com suporte a subscriptions

  # Estado
  flutter_riverpod       # Gerenciamento de estado reativo

  # Utilitários
  uuid                   # Geração de IDs únicos
  intl                   # Formatação de datas
  shared_preferences     # Armazenamento local
  timezone               # Suporte a fusos horários
```

---

## 📁 Estrutura de Pastas

```
lib/
├── main.dart                           # Ponto de entrada
│
├── core/                               # Núcleo da aplicação
│   ├── config/
│   │   ├── app_config.dart            # URLs, chaves, configurações
│   │   └── graphql_config.dart        # Cliente GraphQL (HTTP + WebSocket)
│   ├── constants/
│   │   └── app_constants.dart         # Enums, constantes globais
│   └── services/
│       ├── auth_service.dart          # Autenticação local
│       └── notification_service.dart  # Notificações locais
│
├── data/                               # Camada de dados
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── task_model.dart
│   │   ├── category_model.dart
│   │   ├── task_recurrence_model.dart
│   │   ├── task_note_model.dart
│   │   ├── task_attachment_model.dart
│   │   └── task_history_model.dart
│   ├── graphql/
│   │   ├── queries/                   # Leitura de dados
│   │   ├── mutations/                 # Escrita de dados
│   │   └── subscriptions/             # Tempo real
│   └── repositories/
│       ├── task_repository.dart
│       ├── category_repository.dart
│       └── user_repository.dart
│
└── presentation/                       # Camada de UI
    ├── app.dart                       # MaterialApp com configurações
    ├── providers/
    │   ├── auth_provider.dart         # Estado de autenticação
    │   ├── task_provider.dart         # Estado de tarefas + filtros
    │   ├── category_provider.dart     # Estado de categorias
    │   └── stats_provider.dart        # Estado de estatísticas
    ├── themes/
    │   └── app_theme.dart             # Temas claro/escuro
    ├── screens/
    │   ├── auth/
    │   │   └── login_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── task/
    │   │   └── task_form_screen.dart
    │   ├── category/
    │   │   ├── categories_screen.dart
    │   │   └── category_form_screen.dart
    │   ├── agenda/
    │   │   └── agenda_screen.dart
    │   └── dashboard/                 # Tela de estatísticas
    │       └── dashboard_screen.dart
    └── widgets/
        ├── app_drawer.dart            # Menu lateral
        ├── task_card.dart             # Card de tarefa
        ├── filter_bar.dart            # Barra de filtros
        ├── color_picker.dart          # Seletor de cores
        ├── daily_summary.dart         # Resumo do dia
        └── charts/                    # Widgets de gráficos
            ├── bar_chart_widget.dart  # Gráficos de barras
            ├── progress_ring_widget.dart # Anel circular
            └── stat_card_widget.dart  # Cards de estatísticas
```

---

## 📈 Fases de Desenvolvimento

### Fase 1 - Configuração Base ✅

**Objetivo**: Estabelecer a fundação do projeto.

**Entregas**:

- Projeto Flutter criado com estrutura modular
- Configuração do cliente GraphQL (HTTP + WebSocket)
- Modelos de dados para todas as entidades
- Queries, Mutations e Subscriptions GraphQL
- Repositórios com métodos CRUD
- Tema do aplicativo (claro/escuro)

**Decisões Técnicas**:

- Uso de `GraphQLConfig` como singleton para gerenciar conexões
- WebSocket configurado para subscriptions em tempo real
- Headers de autenticação centralizados em `AppConfig`

---

### Fase 2 - Funcionalidades Básicas ✅

**Objetivo**: Implementar autenticação e filtros.

**Entregas**:

- Serviço de autenticação com SharedPreferences
- Providers Riverpod para estado global
- Tela de login com acesso rápido para testes
- Sistema de filtros (status, prioridade, categoria)
- Ordenação de tarefas (prioridade, data, título)
- Barra de filtros horizontal com chips

**Decisões Técnicas**:

- `AuthService` usa armazenamento local para simplicidade (MVP)
- `TasksState` contém filtros e ordenação no mesmo estado
- Propriedade computada `filteredTasks` aplica filtros em tempo real

**Código Relevante**:

```dart
// Exemplo de filtro computado no TasksState
List<TaskModel> get filteredTasks {
  var result = List<TaskModel>.from(tasks);

  // Aplica filtro de status
  switch (statusFilter) {
    case TaskStatusFilter.pending:
      result = result.where((t) => !t.completed).toList();
      break;
    // ... outros filtros
  }

  return result;
}
```

---

### Fase 3 - Categorias ✅

**Objetivo**: Sistema completo de categorização.

**Entregas**:

- Tela de listagem de categorias
- Formulário de criação/edição
- Seletor de cores com 18 cores predefinidas
- Menu lateral (Drawer) com navegação
- Filtro rápido por categoria

**Decisões Técnicas**:

- `ColorPicker` com grade de cores cuidadosamente selecionadas
- Drawer integrado com providers para contadores em tempo real
- Bottom sheet para seleção de categoria nas tarefas

**Código Relevante**:

```dart
// Cores predefinidas para categorias
const List<String> predefinedColors = [
  '#EF4444', // Vermelho
  '#22C55E', // Verde
  '#3B82F6', // Azul
  // ... 15 cores adicionais
];
```

---

### Fase 4 - Prioridades e Datas ✅

**Objetivo**: Notificações e visualização temporal.

**Entregas**:

- Serviço de notificações locais multiplataforma
- Tela de agenda com navegação por semana
- Seletor de data com calendário em português
- Widget de resumo diário
- Opção de lembrete nas tarefas

**Decisões Técnicas**:

- `NotificationService` como singleton inicializado no `main()`
- Navegação por semana com setas + seletor de data ao clicar no mês
- Localização completa para pt_BR usando `flutter_localizations`

**Código Relevante**:

```dart
// Configuração de localização no MaterialApp
MaterialApp(
  locale: const Locale('pt', 'BR'),
  supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
)
```

---

### Fase 6 - Dashboard e Estatísticas ✅

**Objetivo**: Criar visualização de métricas e produtividade.

**Entregas**:

- Provider de estatísticas com cálculos em tempo real
- Widgets de gráficos customizados (sem dependências externas)
- Tela de dashboard com múltiplas visualizações
- Sistema de streak de conclusão
- Navegação pelo Drawer

**Decisões Técnicas**:

- Gráficos implementados com `CustomPaint` e animações nativas do Flutter
- `statsProvider` deriva dados automaticamente do `tasksProvider`
- Streak calculado baseado em `updatedAt` das tarefas concluídas
- Cards de estatísticas com cores dinâmicas baseadas nos valores

**Arquivos Criados**:

```
lib/presentation/
├── providers/
│   └── stats_provider.dart          # Provider de estatísticas
├── screens/
│   └── dashboard/
│       └── dashboard_screen.dart    # Tela principal
└── widgets/
    └── charts/
        ├── bar_chart_widget.dart    # Gráficos de barras
        ├── progress_ring_widget.dart # Anel de progresso circular
        └── stat_card_widget.dart    # Cards de métricas
```

**Código Relevante**:

```dart
// Provider de estatísticas derivado das tarefas
final statsProvider = Provider<UserStats>((ref) {
  final tasksState = ref.watch(tasksProvider);
  final tasks = tasksState.tasks;
  
  // Cálculos de métricas
  final completedTasks = tasks.where((t) => t.completed).toList();
  final completionRate = tasks.isNotEmpty 
      ? completedTasks.length / tasks.length 
      : 0.0;
  
  return UserStats(
    totalTasks: tasks.length,
    completedTasks: completedTasks.length,
    completionRate: completionRate,
    // ... outras métricas
  );
});
```

**Funcionalidades do Dashboard**:

| Componente | Descrição |
|------------|-----------|
| Saudação dinâmica | Bom dia/tarde/noite baseado na hora |
| Anel de progresso | Taxa de conclusão com animação |
| Cards de estatísticas | Hoje, Atrasadas, Alta prioridade, Média/dia |
| Streak | Dias consecutivos com tarefas concluídas |
| Gráfico semanal | Barras por dia da semana |
| Por categoria | Barras horizontais |
| Por prioridade | Barra empilhada colorida |

---

## 🔧 Configuração do Backend (Hasura)

### Conexão

```dart
// lib/core/config/app_config.dart
static const String hasuraEndpoint =
    'https://flutter-rest-project.hasura.app/v1/graphql';

static const String hasuraWebSocketEndpoint =
    'wss://flutter-rest-project.hasura.app/v1/graphql';
```

### Esquema do Banco de Dados

```sql
-- Tabelas principais
users           -- Usuários do sistema
tasks           -- Tarefas (relacionada a users e categories)
categories      -- Categorias de tarefas
task_recurrence -- Configuração de tarefas recorrentes
task_notes      -- Notas/comentários em tarefas
task_attachments-- Anexos de tarefas
task_history    -- Histórico de conclusão
```

### Exemplo de Query GraphQL

```graphql
query GetTasks($userId: uuid!) {
	tasks(
		where: { user_id: { _eq: $userId } }
		order_by: [
			{ completed: asc }
			{ priority: desc }
			{ due_date: asc_nulls_last }
		]
	) {
		id
		title
		priority
		due_date
		completed
		category {
			id
			name
			color
		}
	}
}
```

---

## 📊 Modelos de Dados

### TaskModel

```dart
class TaskModel extends Equatable {
  final String id;
  final String userId;
  final String? categoryId;
  final String title;
  final String? description;
  final String priority;      // 'low', 'medium', 'high'
  final DateTime? dueDate;
  final String? dueTime;
  final bool completed;
  final String? context;      // 'casa', 'trabalho', etc.
  final CategoryModel? category;

  // Propriedades computadas
  bool get isOverdue => ...;
  bool get isDueToday => ...;
  int get priorityWeight => ...;
}
```

### Tratamento Seguro de JSON

```dart
// Problema: Hasura pode retornar null em campos inesperados
// Solução: Uso de ?.toString() em vez de cast direto

factory TaskModel.fromJson(Map<String, dynamic> json) {
  return TaskModel(
    id: json['id']?.toString() ?? '',           // Seguro
    categoryId: json['category_id']?.toString(), // Nullable seguro
    priority: json['priority']?.toString() ?? TaskPriority.medium,
  );
}
```

---

## 🔄 Gerenciamento de Estado

### Providers Principais

```dart
// Autenticação
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
final currentUserIdProvider = Provider<String?>(...);

// Tarefas
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>(...);
final filteredTasksProvider = Provider<List<TaskModel>>(...);
final taskCountsProvider = Provider<Map<String, int>>(...);

// Categorias
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>(...);
```

### Fluxo de Estado

```
Usuario interage → Provider.notifier → Repository → GraphQL → Hasura
                          ↓
                    Atualiza State
                          ↓
                    UI reconstrói (ref.watch)
```

---

## ✨ Funcionalidades Implementadas

### Tela Principal (HomeScreen)

- [x] Lista de tarefas com cards interativos
- [x] Swipe para deletar
- [x] Checkbox para marcar como concluída
- [x] Pull-to-refresh
- [x] Resumo compacto do dia no topo
- [x] Menu lateral (Drawer)

### Filtros e Ordenação

- [x] Por status: Todas, Pendentes, Hoje, Atrasadas, Concluídas
- [x] Por prioridade: Alta, Média, Baixa
- [x] Por categoria
- [x] Ordenação: Prioridade, Data limite, Criação, Título

### Formulário de Tarefa

- [x] Título e descrição
- [x] Seletor de prioridade (SegmentedButton)
- [x] Data e hora limite
- [x] Categoria (Bottom sheet)
- [x] Contexto (chips)
- [x] Lembrete com opções de antecedência

### Categorias

- [x] CRUD completo
- [x] Seletor de cores (18 opções)
- [x] Ícone colorido no card

### Agenda

- [x] Navegação por semana
- [x] Seletor de data (calendário)
- [x] Resumo do dia selecionado
- [x] Lista de tarefas do dia

### Notificações

- [x] Agendamento de lembretes
- [x] Opções: Na hora, 15min, 30min, 1h, 1 dia antes
- [x] Suporte Android, iOS e Linux

### Dashboard

- [x] Saudação dinâmica (Bom dia/tarde/noite)
- [x] Anel de progresso com taxa de conclusão
- [x] Cards de estatísticas (Hoje, Atrasadas, Alta prioridade, Média/dia)
- [x] Streak de dias consecutivos com ícone de fogo 🔥
- [x] Gráfico de atividade semanal (barras por dia)
- [x] Distribuição por categoria (barras horizontais)
- [x] Distribuição por prioridade (barra empilhada)

---

## 🐛 Problemas Resolvidos

### 1. DropdownMenu não atualizava visualmente

**Problema**: `DropdownMenu` usa `initialSelection` que só é lido uma vez.

**Solução**: Substituído por `InkWell` + `InputDecorator` + `showModalBottomSheet`.

```dart
// Antes (não funcionava)
DropdownMenu<String?>(
  initialSelection: _categoryId,
  onSelected: (value) => setState(() => _categoryId = value),
)

// Depois (funciona)
InkWell(
  onTap: () => _showCategoryPicker(categories),
  child: InputDecorator(...),
)
```

---

### 2. DatePicker sem localização

**Problema**: `No MaterialLocalizations found` ao abrir DatePicker.

**Solução**: Adicionar `flutter_localizations` e configurar no MaterialApp.

```dart
// pubspec.yaml
flutter_localizations:
  sdk: flutter

// app.dart
localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

---

### 3. Erro de cast "Null is not subtype of String"

**Problema**: Hasura pode retornar `null` em campos que esperávamos `String`.

**Solução**: Usar `?.toString()` em vez de `as String` nos fromJson.

```dart
// Antes (quebrava)
id: json['id'] as String,

// Depois (seguro)
id: json['id']?.toString() ?? '',
```

---

### 4. Navegação da Agenda limitada

**Problema**: Setas navegavam por mês inteiro, impossibilitando ver dias específicos.

**Solução**: Setas navegam por semana + clique no mês abre calendário.

```dart
void _goToNextWeek() {
  setState(() {
    _selectedDate = _selectedDate.add(const Duration(days: 7));
  });
}

Future<void> _selectDate() async {
  final picked = await showDatePicker(...);
  if (picked != null) setState(() => _selectedDate = picked);
}
```

---

## 🚀 Como Executar

### Pré-requisitos

- Flutter 3.38+ instalado
- Conta Hasura com projeto configurado
- Usuário de teste criado no banco

### Passos

```bash
# 1. Clone o projeto
cd /home/youx/Documentos/Projetos/flutter

# 2. Instale as dependências
flutter pub get

# 3. Execute o app
flutter run

# 4. Para Linux desktop
flutter run -d linux

# 5. Para Chrome
flutter run -d chrome
```

### Criar Usuário de Teste no Hasura

Execute no console do Hasura:

```graphql
mutation {
	insert_users_one(
		object: {
			id: "00000000-0000-0000-0000-000000000001"
			name: "Usuário Teste"
			email: "teste@email.com"
		}
	) {
		id
	}
}
```

### Login no App

1. Abra o app
2. Clique em **"Entrar com usuário de teste"**
3. Pronto! Você está logado.

---

## 📝 Próximas Etapas

### Fase 5 - Funcionalidades Inteligentes (Pendente)

- [ ] Sugestão automática de prioridade
- [ ] Tarefas recorrentes
- [ ] Parser de texto natural para criação rápida
- [ ] Resumo diário ao abrir o app

### Fase 6 - Dashboard e Estatísticas ✅

- [x] Tela de dashboard
- [x] Gráficos de produtividade
- [x] Streak de conclusão
- [ ] Histórico de tarefas detalhado

---

## 👥 Contribuição

Este projeto foi desenvolvido como trabalho de faculdade, demonstrando:

- Desenvolvimento Flutter profissional
- Integração com GraphQL/Hasura
- Gerenciamento de estado com Riverpod
- Boas práticas de arquitetura
- UI/UX com Material Design 3

---

_Documentação atualizada em: 03 de Dezembro de 2024_
