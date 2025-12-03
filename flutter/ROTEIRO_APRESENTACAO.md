# 📊 Roteiro de Apresentação - Smart Task List

## 🎯 Informações Gerais

- **Duração sugerida:** 15-20 minutos
- **Projeto:** Smart Task List - Aplicativo de Gerenciamento de Tarefas Inteligente
- **Stack:** Flutter + Hasura GraphQL + Riverpod

---

## 📑 Índice da Apresentação

1. [Introdução e Visão Geral](#1-introdução-e-visão-geral-2-min)
2. [Arquitetura e Stack Tecnológica](#2-arquitetura-e-stack-tecnológica-3-min)
3. [Demonstração das Funcionalidades](#3-demonstração-das-funcionalidades-5-min)
4. [Destaques Técnicos do Código](#4-destaques-técnicos-do-código-5-min)
5. [Desafios e Soluções](#5-desafios-e-soluções-3-min)
6. [Conclusão](#6-conclusão-2-min)

---

## 1. Introdução e Visão Geral (2 min)

### 🎤 O que falar:

> "O Smart Task List é um aplicativo de gerenciamento de tarefas desenvolvido em Flutter, que vai além de um simples to-do list. O objetivo foi criar um sistema completo com funcionalidades inteligentes como filtros avançados, visualização em agenda, dashboard de estatísticas e notificações locais."

### 📌 Pontos-chave:

- **Problema:** Apps de tarefas simples não oferecem visão analítica de produtividade
- **Solução:** App completo com CRUD, filtros, agenda, notificações e dashboard
- **Diferencial:** Conexão em tempo real com backend GraphQL e gráficos customizados

### 📊 Slide sugerido:

| Funcionalidade | Descrição |
|---------------|-----------|
| CRUD de Tarefas | Criar, editar, excluir, marcar como concluída |
| Categorias | Organização por projetos/áreas |
| Filtros | Status, prioridade, categoria |
| Agenda | Visualização por semana |
| Dashboard | Gráficos e estatísticas |
| Notificações | Lembretes locais |

---

## 2. Arquitetura e Stack Tecnológica (3 min)

### 🎤 O que falar:

> "O projeto segue uma arquitetura em camadas baseada em Clean Architecture simplificada, separando responsabilidades entre apresentação, dados e core. Utilizamos Flutter 3.38, Hasura como backend GraphQL e Riverpod para gerenciamento de estado."

### 📌 Mostrar no código:

**Estrutura de pastas (abrir explorador de arquivos):**

```
lib/
├── main.dart                    # Ponto de entrada
├── core/                        # Configurações e serviços globais
│   ├── config/                  # GraphQL, URLs
│   └── services/                # Notificações, Auth
├── data/                        # Camada de dados
│   ├── models/                  # TaskModel, CategoryModel
│   ├── graphql/                 # Queries e Mutations
│   └── repositories/            # Acesso a dados
└── presentation/                # Camada de UI
    ├── providers/               # Estado (Riverpod)
    ├── screens/                 # Telas
    ├── widgets/                 # Componentes
    └── themes/                  # Tema do app
```

### 🔍 Arquivo para mostrar: `lib/main.dart`

> "Aqui vemos o ponto de entrada que inicializa o GraphQL, notificações e envolve o app com Riverpod."

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  await initializeDateFormatting('pt_BR', null);
  await NotificationService().initialize();
  
  runApp(const ProviderScope(child: SmartTaskListApp()));
}
```

### 📊 Diagrama de arquitetura:

```
┌─────────────────────────────────────────┐
│           PRESENTATION                   │
│  (Screens, Widgets, Providers, Themes)  │
├─────────────────────────────────────────┤
│              DATA                        │
│  (Models, Repositories, GraphQL)        │
├─────────────────────────────────────────┤
│              CORE                        │
│  (Config, Services, Constants)          │
├─────────────────────────────────────────┤
│     HASURA GRAPHQL (Backend)            │
│         PostgreSQL                       │
└─────────────────────────────────────────┘
```

---

## 3. Demonstração das Funcionalidades (5 min)

### 🎮 Roteiro de Demo no App:

#### 3.1 Tela de Login (30 seg)
- Mostrar tela de login
- Clicar em "Entrar com usuário de teste"

#### 3.2 Tela Principal - HomeScreen (1 min)
- **Mostrar:** Lista de tarefas com cards coloridos
- **Destacar:**
  - Borda colorida indica prioridade (vermelho = alta, amarelo = média, verde = baixa)
  - Chips mostram data, categoria e contexto
  - Resumo do dia no topo

#### 3.3 Filtros e Ordenação (1 min)
- **Mostrar:** Barra de filtros horizontal
- **Demonstrar:**
  - Filtro por status (Pendentes, Hoje, Atrasadas, Concluídas)
  - Filtro por prioridade
  - Filtro por categoria
  - Ordenação (prioridade, data, título)

#### 3.4 Criar/Editar Tarefa (1 min)
- **Mostrar:** Formulário de tarefa
- **Destacar:**
  - Seletor de prioridade (SegmentedButton)
  - Seletor de data e hora
  - Seleção de categoria (Bottom Sheet)
  - Contexto (Casa, Trabalho, Rua)
  - Opção de lembrete

#### 3.5 Agenda (30 seg)
- **Mostrar:** Tela de agenda
- **Demonstrar:**
  - Navegação por semana (setas)
  - Seletor de data (clique no mês)
  - Resumo do dia selecionado

#### 3.6 Dashboard (1 min)
- **Mostrar:** Tela de estatísticas
- **Destacar:**
  - Saudação dinâmica (Bom dia/tarde/noite)
  - Anel de progresso animado
  - Cards de estatísticas
  - Streak de dias consecutivos 🔥
  - Gráfico de atividade semanal
  - Distribuição por categoria e prioridade

---

## 4. Destaques Técnicos do Código (5 min)

### 4.1 Modelo de Dados - TaskModel

> "O modelo de tarefa usa Equatable para comparação eficiente e possui propriedades computadas inteligentes."

**Arquivo:** `lib/data/models/task_model.dart`

```dart
/// Verifica se a tarefa está atrasada.
bool get isOverdue {
  if (completed || dueDate == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return dueDate!.isBefore(today);
}

/// Verifica se a tarefa vence hoje.
bool get isDueToday {
  if (dueDate == null) return false;
  final now = DateTime.now();
  return dueDate!.year == now.year &&
         dueDate!.month == now.month &&
         dueDate!.day == now.day;
}
```

### 4.2 Gerenciamento de Estado - Riverpod

> "Usamos Riverpod com StateNotifier para gerenciar o estado das tarefas, incluindo filtros e ordenação no mesmo estado."

**Arquivo:** `lib/presentation/providers/task_provider.dart`

```dart
/// Estado completo das tarefas com filtros integrados
class TasksState {
  final List<TaskModel> tasks;
  final TaskStatusFilter statusFilter;
  final String? priorityFilter;
  final String? categoryFilter;
  final TaskSortOrder sortOrder;

  /// Retorna as tarefas filtradas e ordenadas (propriedade computada)
  List<TaskModel> get filteredTasks {
    var result = List<TaskModel>.from(tasks);
    
    // Aplica filtros...
    switch (statusFilter) {
      case TaskStatusFilter.pending:
        result = result.where((t) => !t.completed).toList();
        break;
      // ...
    }
    
    return result;
  }
}
```

### 4.3 Integração GraphQL

> "O cliente GraphQL é configurado como Singleton com suporte a HTTP para queries/mutations e WebSocket para subscriptions em tempo real."

**Arquivo:** `lib/core/config/graphql_config.dart`

```dart
/// Link combinado que roteia operações
Link get _link => Link.split(
  (request) => request.isSubscription,
  _webSocketLink,  // Subscriptions via WebSocket
  _httpLink,       // Queries/Mutations via HTTP
);
```

**Arquivo:** `lib/data/graphql/queries/task_queries.dart`

```graphql
query GetTasks($userId: uuid!) {
  tasks(
    where: { user_id: { _eq: $userId } }
    order_by: [
      { completed: asc },
      { priority: desc },
      { due_date: asc_nulls_last }
    ]
  ) {
    id, title, priority, due_date, completed
    category { id, name, color }
  }
}
```

### 4.4 Gráficos Customizados com CustomPaint

> "Os gráficos do Dashboard foram implementados sem bibliotecas externas, usando CustomPaint do Flutter com animações nativas."

**Arquivo:** `lib/presentation/widgets/charts/progress_ring_widget.dart`

```dart
/// Painter customizado para desenhar o anel de progresso
class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Gradiente para efeito visual
    paint.shader = SweepGradient(
      colors: [color.withOpacity(0.3), color],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawArc(...);
  }
}
```

### 4.5 Provider de Estatísticas

> "As estatísticas são calculadas automaticamente a partir das tarefas, incluindo streak de conclusão."

**Arquivo:** `lib/presentation/providers/stats_provider.dart`

```dart
/// Provider que deriva estatísticas das tarefas
final statsProvider = Provider<UserStats>((ref) {
  final tasks = ref.watch(tasksProvider).tasks;
  
  // Taxa de conclusão
  final completionRate = tasks.isNotEmpty 
      ? completedTasks.length / tasks.length 
      : 0.0;
  
  // Streak calculado
  final streakData = _calculateStreak(completedTasks);
  
  return UserStats(
    completionRate: completionRate,
    currentStreak: streakData['current'] ?? 0,
    // ...
  );
});
```

---

## 5. Desafios e Soluções (3 min)

### 🎤 O que falar:

> "Durante o desenvolvimento, enfrentamos alguns desafios técnicos interessantes. Vou destacar três deles:"

### 5.1 DropdownMenu não atualizava visualmente

**Problema:** O `DropdownMenu` do Flutter usa `initialSelection` que é lido apenas uma vez.

**Solução:** Substituímos por `InkWell` + `InputDecorator` + `showModalBottomSheet`.

```dart
// Antes (não funcionava)
DropdownMenu<String?>(
  initialSelection: _categoryId,
  onSelected: (value) => setState(() => _categoryId = value),
)

// Depois (funciona)
InkWell(
  onTap: () => _showCategoryPicker(categories),
  child: InputDecorator(
    decoration: InputDecoration(labelText: 'Categoria'),
    child: Text(selectedCategory?.name ?? 'Nenhuma'),
  ),
)
```

### 5.2 DatePicker sem localização

**Problema:** Erro "No MaterialLocalizations found" ao abrir o calendário.

**Solução:** Adicionar delegates de localização e configurar idioma português.

```dart
MaterialApp(
  locale: const Locale('pt', 'BR'),
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
)
```

### 5.3 Erro de cast com dados null do Hasura

**Problema:** O Hasura pode retornar `null` em campos que esperávamos `String`, causando erros de cast.

**Solução:** Usar `?.toString()` em vez de `as String` no fromJson.

```dart
// Antes (quebrava)
id: json['id'] as String,

// Depois (seguro)
id: json['id']?.toString() ?? '',
```

---

## 6. Conclusão (2 min)

### 🎤 O que falar:

> "O Smart Task List demonstra uma aplicação Flutter profissional com arquitetura robusta, integração GraphQL em tempo real e interface moderna com Material Design 3."

### 📊 Resumo do Progresso:

| Fase | Status | Descrição |
|------|--------|-----------|
| Fase 1 - Base | ✅ 100% | Estrutura, GraphQL, Models |
| Fase 2 - CRUD | ✅ 100% | Autenticação, Filtros |
| Fase 3 - Categorias | ✅ 100% | CRUD categorias, Drawer |
| Fase 4 - Datas | ✅ 100% | Agenda, Notificações |
| Fase 5 - IA | ⏸️ Futura | Sugestões automáticas |
| Fase 6 - Dashboard | ✅ 75% | Estatísticas, Gráficos |

### 💡 Tecnologias e conceitos demonstrados:

- ✅ Flutter 3.38 com Material Design 3
- ✅ Arquitetura em camadas (Clean Architecture)
- ✅ Riverpod para gerenciamento de estado
- ✅ GraphQL com Hasura Cloud
- ✅ WebSocket para dados em tempo real
- ✅ CustomPaint para gráficos animados
- ✅ Notificações locais multiplataforma
- ✅ Localização pt_BR completa

### 🚀 Próximos passos (mencionais se perguntarem):

- Sugestão automática de prioridade com IA
- Tarefas recorrentes
- Parser de texto natural ("Comprar leite amanhã às 10h")
- Autenticação OAuth (Google, Apple)

---

## 📁 Arquivos para ter abertos durante a apresentação

1. `lib/main.dart` - Ponto de entrada
2. `lib/presentation/screens/home/home_screen.dart` - Tela principal
3. `lib/presentation/providers/task_provider.dart` - Estado
4. `lib/data/models/task_model.dart` - Modelo de dados
5. `lib/presentation/screens/dashboard/dashboard_screen.dart` - Dashboard
6. `lib/presentation/widgets/charts/progress_ring_widget.dart` - Gráfico customizado

---

## 🎬 Dicas para a Apresentação

1. **Antes de começar:**
   - Tenha o app rodando em um emulador ou dispositivo físico
   - Crie algumas tarefas de exemplo com diferentes prioridades e datas

2. **Durante a apresentação:**
   - Alterne entre código e demonstração no app
   - Use o tema claro para melhor visualização
   - Demonstre filtros aplicando e removendo em sequência

3. **Se perguntarem sobre:**
   - **Segurança:** Mencione que o Hasura usa header de autenticação
   - **Performance:** Cache em memória com GraphQL, rebuild otimizado do Riverpod
   - **Testes:** Estrutura preparada na pasta `/test`, Widget tests disponíveis

---

_Roteiro criado em: 03 de Dezembro de 2025_

