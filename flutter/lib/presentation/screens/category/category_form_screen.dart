/// Tela de formulário para criar/editar categorias.
///
/// Este arquivo contém o formulário completo para
/// criação e edição de categorias com seleção de cor.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/color_picker.dart';

/// Tela de formulário para criar ou editar uma categoria.
///
/// Se [category] for fornecido, edita a categoria existente.
/// Caso contrário, cria uma nova categoria.
class CategoryFormScreen extends ConsumerStatefulWidget {
  /// Categoria a ser editada (null para criar nova).
  final CategoryModel? category;

  /// Construtor padrão.
  const CategoryFormScreen({
    super.key,
    this.category,
  });

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  /// Chave do formulário para validação.
  final _formKey = GlobalKey<FormState>();

  /// Gerador de UUIDs.
  final Uuid _uuid = const Uuid();

  /// Controlador do campo de nome.
  late TextEditingController _nameController;

  /// Cor selecionada (formato hex).
  String _selectedColor = predefinedColors[4]; // Verde como padrão

  /// Indica se está salvando.
  bool _isSaving = false;

  /// Indica se é modo de edição.
  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Inicializa os campos do formulário.
  void _initializeForm() {
    final category = widget.category;

    _nameController = TextEditingController(text: category?.name ?? '');
    _selectedColor = category?.color ?? predefinedColors[4];
  }

  /// Salva a categoria.
  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: usuário não autenticado'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final categoriesNotifier = ref.read(categoriesProvider.notifier);

      if (_isEditing) {
        // Atualiza categoria existente
        await categoriesNotifier.updateCategory(widget.category!.id, {
          'name': _nameController.text.trim(),
          'color': _selectedColor,
        });
      } else {
        // Cria nova categoria
        final newCategory = CategoryModel(
          id: _uuid.v4(),
          userId: userId,
          name: _nameController.text.trim(),
          color: _selectedColor,
        );
        await categoriesNotifier.createCategory(newCategory);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Categoria atualizada com sucesso'
                  : 'Categoria criada com sucesso',
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
            content: Text('Erro ao salvar categoria: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Abre o dialog de seleção de cor.
  Future<void> _selectColor() async {
    final color = await ColorPickerDialog.show(
      context,
      initialColor: _selectedColor,
    );

    if (color != null) {
      setState(() => _selectedColor = color);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Categoria' : 'Nova Categoria'),
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
              onPressed: _saveCategory,
              tooltip: 'Salvar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview da categoria
              _buildPreview(),
              const SizedBox(height: 24),

              // Campo de nome
              _buildNameField(),
              const SizedBox(height: 24),

              // Seletor de cor
              _buildColorSection(),
              const SizedBox(height: 32),

              // Botão de salvar
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o preview da categoria.
  Widget _buildPreview() {
    final color = _hexToColor(_selectedColor);
    final name = _nameController.text.isEmpty
        ? 'Nome da Categoria'
        : _nameController.text;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.folder,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o campo de nome.
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome da Categoria *',
        hintText: 'Ex: Trabalho, Casa, Estudos...',
        prefixIcon: Icon(Icons.label_outline),
      ),
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() {}), // Atualiza preview
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, informe o nome da categoria';
        }
        if (value.trim().length < 2) {
          return 'O nome deve ter pelo menos 2 caracteres';
        }
        return null;
      },
    );
  }

  /// Constrói a seção de seleção de cor.
  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cor da Categoria',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha uma cor para identificar visualmente a categoria',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 16),

        // Grade de cores
        ColorPicker(
          selectedColor: _selectedColor,
          onColorSelected: (color) {
            setState(() => _selectedColor = color);
          },
        ),

        const SizedBox(height: 16),

        // Botão para dialog (alternativa)
        OutlinedButton.icon(
          onPressed: _selectColor,
          icon: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _hexToColor(_selectedColor),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          label: Text('Cor selecionada: $_selectedColor'),
        ),
      ],
    );
  }

  /// Constrói o botão de salvar.
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _saveCategory,
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
        label: Text(_isEditing ? 'Salvar Alterações' : 'Criar Categoria'),
      ),
    );
  }

  /// Converte hex para Color.
  Color _hexToColor(String hex) {
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}

