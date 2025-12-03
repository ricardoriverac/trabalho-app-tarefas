# 📋 Smart Task List - Planejamento do Projeto

## 🎯 Visão Geral

Aplicativo de Lista de Tarefas inteligente desenvolvido com Flutter + Hasura GraphQL.
O objetivo é criar um sistema que vai além de um simples to-do list, incorporando
funcionalidades inteligentes como sugestões automáticas, assistente por chat e análise
de produtividade.

## 🏗️ Arquitetura

### Stack Tecnológica

- **Frontend:** Flutter 3.38+
- **Backend:** Hasura GraphQL Engine
- **Banco de Dados:** PostgreSQL (via Hasura)
- **Protocolo:** GraphQL (queries, mutations, subscriptions)

### Padrão Arquitetural

Utilizamos uma arquitetura em camadas baseada em **Clean Architecture simplificada**:

```
lib/
├── core/                    # Configurações e utilidades globais
│   ├── config/              # Configurações do app (API, temas, etc.)
│   ├── constants/           # Constantes globais
│   ├── errors/              # Classes de erro customizadas
│   └── utils/               # Funções utilitárias
├── data/                    # Camada de dados
│   ├── models/              # Modelos de dados (DTOs)
│   ├── repositories/        # Implementação dos repositórios
│   └── datasources/         # Fontes de dados (GraphQL client)
├── domain/                  # Regras de negócio
│   ├── entities/            # Entidades de domínio
│   └── usecases/            # Casos de uso
├── presentation/            # Camada de apresentação
│   ├── screens/             # Telas do app
│   ├── widgets/             # Widgets reutilizáveis
│   ├── providers/           # State management (Riverpod/Provider)
│   └── themes/              # Temas e estilos
└── main.dart                # Ponto de entrada
```

## 🗄️ Modelo de Dados

### Entidades Principais

1. **User** - Usuário do sistema
2. **Task** - Tarefa principal
3. **Category** - Categorias/Projetos
4. **TaskRecurrence** - Recorrência de tarefas
5. **TaskNote** - Notas/comentários
6. **TaskAttachment** - Anexos
7. **TaskHistory** - Histórico de conclusão

### Relacionamentos

```
User (1) ─────┬────── (*) Task
              ├────── (*) Category
              └────── (*) TaskNote

Task (1) ─────┬────── (0..1) Category
              ├────── (0..1) TaskRecurrence
              ├────── (*) TaskNote
              ├────── (*) TaskAttachment
              └────── (*) TaskHistory
```

## 🎨 Padrões de Código

### Nomenclatura

- **Classes:** PascalCase (`TaskRepository`, `UserModel`)
- **Arquivos:** snake_case (`task_repository.dart`, `user_model.dart`)
- **Variáveis/Funções:** camelCase (`taskList`, `fetchTasks()`)
- **Constantes:** SCREAMING_SNAKE_CASE (`MAX_TASKS_PER_PAGE`)

### Convenções

- Todos os métodos públicos devem ter documentação (/// comments)
- Type hints obrigatórios em todos os parâmetros e retornos
- Comentários explicativos em português brasileiro
- Arquivos com no máximo 500 linhas

## 🔐 Configuração do Hasura

- **Endpoint:** `https://flutter-rest-project.hasura.app/v1/graphql`
- **Autenticação:** Header `x-hasura-admin-secret`

## 📦 Dependências Principais

- `graphql_flutter` - Cliente GraphQL
- `flutter_riverpod` - Gerenciamento de estado
- `go_router` - Navegação
- `uuid` - Geração de UUIDs
- `intl` - Internacionalização e formatação de datas
- `flutter_local_notifications` - Notificações locais

## 🚀 Fases de Desenvolvimento

### Fase 1 - Base (Atual)

- [x] Criar projeto Flutter
- [ ] Configurar dependências
- [ ] Configurar cliente GraphQL
- [ ] Criar modelos de dados
- [ ] Criar repositórios base

### Fase 2 - CRUD Básico

- [ ] Tela de listagem de tarefas
- [ ] Criação/edição de tarefas
- [ ] Exclusão de tarefas
- [ ] Marcar como concluída

### Fase 3 - Categorias e Filtros

- [ ] CRUD de categorias
- [ ] Filtros por categoria
- [ ] Filtros por prioridade
- [ ] Ordenação

### Fase 4 - Funcionalidades Inteligentes

- [ ] Sugestão automática de prioridade
- [ ] Tarefas recorrentes
- [ ] Assistente de criação rápida

### Fase 5 - IA e Analytics

- [ ] Resumo diário
- [ ] Chat com assistente
- [ ] Dashboard de estatísticas
