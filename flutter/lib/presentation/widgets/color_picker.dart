/// Widget de seleção de cor para categorias.
///
/// Este widget exibe uma grade de cores para o usuário selecionar.
library;

import 'package:flutter/material.dart';

/// Lista de cores predefinidas para categorias.
///
/// Reason: Cores cuidadosamente selecionadas para boa visibilidade
/// tanto em temas claros quanto escuros.
const List<String> predefinedColors = [
  '#EF4444', // Vermelho
  '#F97316', // Laranja
  '#F59E0B', // Âmbar
  '#EAB308', // Amarelo
  '#84CC16', // Lima
  '#22C55E', // Verde
  '#10B981', // Esmeralda
  '#14B8A6', // Teal
  '#06B6D4', // Ciano
  '#0EA5E9', // Azul claro
  '#3B82F6', // Azul
  '#6366F1', // Índigo
  '#8B5CF6', // Violeta
  '#A855F7', // Roxo
  '#D946EF', // Fúcsia
  '#EC4899', // Rosa
  '#F43F5E', // Rosa escuro
  '#78716C', // Cinza
];

/// Widget de seleção de cor em grade.
///
/// Exibe uma grade de cores predefinidas para o usuário selecionar.
class ColorPicker extends StatelessWidget {
  /// Cor atualmente selecionada (em formato hex).
  final String? selectedColor;

  /// Callback chamado quando uma cor é selecionada.
  final ValueChanged<String> onColorSelected;

  /// Número de colunas na grade.
  final int crossAxisCount;

  /// Construtor padrão.
  const ColorPicker({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
    this.crossAxisCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: predefinedColors.length,
      itemBuilder: (context, index) {
        final colorHex = predefinedColors[index];
        final isSelected = selectedColor?.toUpperCase() == colorHex.toUpperCase();

        return _ColorItem(
          colorHex: colorHex,
          isSelected: isSelected,
          onTap: () => onColorSelected(colorHex),
        );
      },
    );
  }
}

/// Item individual de cor na grade.
class _ColorItem extends StatelessWidget {
  final String colorHex;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorItem({
    required this.colorHex,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(colorHex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: _getContrastColor(color),
                size: 20,
              )
            : null,
      ),
    );
  }

  /// Converte hex para Color.
  Color _hexToColor(String hex) {
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  /// Retorna cor de contraste (branco ou preto) baseado na luminosidade.
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Dialog de seleção de cor.
///
/// Exibe um dialog com a grade de cores para seleção.
class ColorPickerDialog extends StatefulWidget {
  /// Cor inicial selecionada.
  final String? initialColor;

  /// Construtor padrão.
  const ColorPickerDialog({
    super.key,
    this.initialColor,
  });

  /// Exibe o dialog e retorna a cor selecionada.
  static Future<String?> show(
    BuildContext context, {
    String? initialColor,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) => ColorPickerDialog(initialColor: initialColor),
    );
  }

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Cor'),
      content: SizedBox(
        width: double.maxFinite,
        child: ColorPicker(
          selectedColor: _selectedColor,
          onColorSelected: (color) {
            setState(() => _selectedColor = color);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selectedColor != null
              ? () => Navigator.pop(context, _selectedColor)
              : null,
          child: const Text('Selecionar'),
        ),
      ],
    );
  }
}

