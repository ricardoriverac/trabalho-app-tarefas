/// Tela de formulário para criar/editar tarefas.
///
/// Este arquivo contém a tela com formulário completo para
/// criação e edição de tarefas com validação.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/task_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/task_provider.dart';
import '../../themes/app_theme.dart';

/// Tela de formulário para criar ou editar uma tarefa.
///
/// Se [task] for fornecido, edita a tarefa existente.
/// Caso contrário, cria uma nova tarefa.
class TaskFormScreen extends ConsumerStatefulWidget {
  /// Tarefa a ser editada (null para criar nova).
  final TaskModel? task;

  /// ID do usuário atual.
  final String userId;

  /// Construtor padrão.
  const TaskFormScreen({super.key, this.task, required this.userId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  /// Chave do formulário para validação.
  final _formKey = GlobalKey<FormState>();

  /// Gerador de UUIDs.
  final Uuid _uuid = const Uuid();

  // Controladores de texto
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  // Estado do formulário
  String _priority = TaskPriority.medium;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String? _categoryId;
  String? _context;
  bool _enableReminder = false;
  int _reminderMinutesBefore = 30;

  // Estado de carregamento
  bool _isSaving = false;

  /// Indica se é modo de edição.
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    // Carrega categorias se ainda não foram carregadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesState = ref.read(categoriesProvider);
      if (categoriesState.categories.isEmpty) {
        ref.read(categoriesProvider.notifier).loadCategories();
      }
    });
  }

  /// Inicializa os campos do formulário.
  void _initializeForm() {
    final task = widget.task;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
    _categoryId = task?.categoryId;
    _context = task?.context;

    // Converte string de hora para TimeOfDay
    if (task?.dueTime != null) {
      final parts = task!.dueTime!.split(':');
      _dueTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  /// Salva a tarefa (cria ou atualiza).
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Converte TimeOfDay para string
      String? dueTimeString;
      if (_dueTime != null) {
        dueTimeString =
            '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}:00';
      }

      final tasksNotifier = ref.read(tasksProvider.notifier);

      if (_isEditing) {
        // Atualiza tarefa existente
        await tasksNotifier.updateTask(widget.task!.id, {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'priority': _priority,
          'due_date': _dueDate?.toIso8601String().split('T').first,
          'due_time': dueTimeString,
          'category_id': _categoryId,
          'context': _context,
        });
      } else {
        // Cria nova tarefa
        final newTask = TaskModel(
          id: _uuid.v4(),
          userId: widget.userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
          dueTime: dueTimeString,
          categoryId: _categoryId,
          context: _context,
        );
        await tasksNotifier.createTask(newTask);

        // Agenda notificação se habilitada
        if (_enableReminder && _dueDate != null) {
          await _scheduleReminder(newTask.id, newTask.title);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Tarefa atualizada com sucesso'
                  : 'Tarefa criada com sucesso',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar tarefa: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Seleciona a data limite.
  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  /// Seleciona a hora limite.
  Future<void> _selectDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  /// Agenda uma notificação de lembrete para a tarefa.
  Future<void> _scheduleReminder(String taskId, String taskTitle) async {
    if (_dueDate == null) return;

    // Calcula a data/hora do lembrete
    DateTime reminderDateTime;

    if (_dueTime != null) {
      // Se tem hora definida, usa ela
      reminderDateTime = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime!.hour,
        _dueTime!.minute,
      ).subtract(Duration(minutes: _reminderMinutesBefore));
    } else {
      // Se não tem hora, lembra às 9h do dia
      reminderDateTime = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        9,
        0,
      );
    }

    // Não agenda se a data já passou
    if (reminderDateTime.isBefore(DateTime.now())) {
      return;
    }

    await NotificationService().scheduleTaskReminder(
      taskId: taskId,
      title: '📋 Lembrete de Tarefa',
      body: taskTitle,
      scheduledDate: reminderDateTime,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final categories = categoriesState.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveTask,
              tooltip: 'Salvar',
            ),
        ],
      ),
      body: categoriesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    _buildTitleField(),
                    const SizedBox(height: 16),

                    // Descrição
                    _buildDescriptionField(),
                    const SizedBox(height: 24),

                    // Prioridade
                    _buildPrioritySelector(),
                    const SizedBox(height: 24),

                    // Data e Hora
                    _buildDateTimeSection(),
                    const SizedBox(height: 24),

                    // Categoria
                    _buildCategorySelector(categories),
                    const SizedBox(height: 24),

                    // Contexto
                    _buildContextSelector(),
                    const SizedBox(height: 24),

                    // Lembrete
                    _buildReminderSection(),
                    const SizedBox(height: 32),

                    // Botão de salvar
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  /// Constrói o campo de título.
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Título *',
        hintText: 'O que você precisa fazer?',
        prefixIcon: Icon(Icons.title),
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, informe o título da tarefa';
        }
        return null;
      },
    );
  }

  /// Constrói o campo de descrição.
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descrição',
        hintText: 'Adicione detalhes sobre a tarefa...',
        prefixIcon: Icon(Icons.notes),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Constrói o seletor de prioridade.
  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prioridade', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: TaskPriority.all.map((priority) {
            return ButtonSegment<String>(
              value: priority,
              label: Text(TaskPriority.getLabel(priority)),
              icon: Icon(
                AppTheme.getPriorityIcon(priority),
                color: AppTheme.getPriorityColor(priority),
              ),
            );
          }).toList(),
          selected: {_priority},
          onSelectionChanged: (selection) {
            setState(() => _priority = selection.first);
          },
        ),
      ],
    );
  }

  /// Constrói a seção de data e hora.
  Widget _buildDateTimeSection() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data e Hora Limite',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Data
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectDueDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _dueDate != null
                      ? dateFormat.format(_dueDate!)
                      : 'Selecionar Data',
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Hora
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectDueTime,
                icon: const Icon(Icons.access_time),
                label: Text(
                  _dueTime != null
                      ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
                      : 'Selecionar Hora',
                ),
              ),
            ),
          ],
        ),
        if (_dueDate != null || _dueTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _dueDate = null;
                  _dueTime = null;
                });
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Limpar data/hora'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
          ),
      ],
    );
  }

  /// Constrói o seletor de categoria.
  Widget _buildCategorySelector(List<CategoryModel> categories) {
    // Encontra a categoria selecionada para exibir
    final selectedCategory = _categoryId != null
        ? categories.where((c) => c.id == _categoryId).firstOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categoria', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showCategoryPicker(categories),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.folder_outlined),
              suffixIcon: _categoryId != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _categoryId = null),
                    )
                  : const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (selectedCategory != null) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: selectedCategory.colorValue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  selectedCategory?.name ?? 'Selecione uma categoria',
                  style: selectedCategory == null
                      ? TextStyle(color: Colors.grey.shade600)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Exibe o seletor de categoria em um bottom sheet.
  void _showCategoryPicker(List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Selecione uma categoria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Opção sem categoria
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('Sem categoria'),
                selected: _categoryId == null,
                onTap: () {
                  setState(() => _categoryId = null);
                  Navigator.pop(context);
                },
              ),
              // Lista de categorias
              ...categories.map((category) {
                final isSelected = _categoryId == category.id;
                return ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: category.colorValue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.folder,
                      size: 16,
                      color: category.colorValue,
                    ),
                  ),
                  title: Text(category.name),
                  selected: isSelected,
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _categoryId = category.id);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Constrói o seletor de contexto.
  Widget _buildContextSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contexto', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildContextChip(null, 'Nenhum', Icons.remove),
            ...TaskContext.all.map((ctx) {
              return _buildContextChip(
                ctx,
                ctx[0].toUpperCase() + ctx.substring(1),
                _getContextIcon(ctx),
              );
            }),
          ],
        ),
      ],
    );
  }

  /// Constrói um chip de contexto.
  Widget _buildContextChip(String? value, String label, IconData icon) {
    final isSelected = _context == value;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() => _context = selected ? value : null);
      },
    );
  }

  /// Retorna o ícone correspondente ao contexto.
  IconData _getContextIcon(String context) {
    switch (context) {
      case TaskContext.home:
        return Icons.home;
      case TaskContext.work:
        return Icons.work;
      case TaskContext.outside:
        return Icons.directions_walk;
      case TaskContext.computer:
        return Icons.computer;
      case TaskContext.phone:
        return Icons.phone;
      default:
        return Icons.label;
    }
  }

  /// Constrói a seção de lembrete.
  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Lembrete',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Switch(
              value: _enableReminder,
              onChanged: _dueDate != null
                  ? (value) => setState(() => _enableReminder = value)
                  : null,
            ),
          ],
        ),
        if (_dueDate == null)
          Text(
            'Defina uma data limite para habilitar lembretes',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        if (_enableReminder && _dueDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Lembrar:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildReminderChip(0, 'Na hora'),
              _buildReminderChip(15, '15 min antes'),
              _buildReminderChip(30, '30 min antes'),
              _buildReminderChip(60, '1 hora antes'),
              _buildReminderChip(1440, '1 dia antes'),
            ],
          ),
        ],
      ],
    );
  }

  /// Constrói um chip de opção de lembrete.
  Widget _buildReminderChip(int minutes, String label) {
    final isSelected = _reminderMinutesBefore == minutes;

    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          setState(() => _reminderMinutesBefore = minutes);
        }
      },
    );
  }

  /// Constrói o botão de salvar.
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _saveTask,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check),
        label: Text(_isEditing ? 'Salvar Alterações' : 'Criar Tarefa'),
      ),
    );
  }
}
