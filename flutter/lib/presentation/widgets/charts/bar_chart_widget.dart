/// Widget de gráfico de barras customizado.
///
/// Gráfico de barras simples usando apenas Flutter,
/// sem dependências externas.
library;

import 'package:flutter/material.dart';

/// Representa um item de dados para o gráfico de barras.
class BarChartItem {
  /// Rótulo do item (ex: "Seg", "Ter").
  final String label;

  /// Valor numérico.
  final double value;

  /// Cor da barra (opcional).
  final Color? color;

  const BarChartItem({
    required this.label,
    required this.value,
    this.color,
  });
}

/// Widget de gráfico de barras verticais.
class BarChartWidget extends StatelessWidget {
  /// Lista de itens do gráfico.
  final List<BarChartItem> items;

  /// Altura máxima das barras.
  final double maxBarHeight;

  /// Largura das barras.
  final double barWidth;

  /// Cor padrão das barras.
  final Color defaultColor;

  /// Se deve mostrar os valores acima das barras.
  final bool showValues;

  /// Se deve mostrar as linhas de grade.
  final bool showGrid;

  const BarChartWidget({
    super.key,
    required this.items,
    this.maxBarHeight = 150,
    this.barWidth = 32,
    this.defaultColor = Colors.blue,
    this.showValues = true,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Sem dados disponíveis'),
      );
    }

    // Encontra o valor máximo para escalar as barras
    final maxValue = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxValue > 0 ? maxValue : 1;

    // Altura para valores e rótulos (texto + espaçamento)
    const double labelAreaHeight = 24;
    const double valueAreaHeight = 20;

    return Column(
      children: [
        // Área dos valores acima das barras
        if (showValues)
          SizedBox(
            height: valueAreaHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((item) {
                return SizedBox(
                  width: barWidth,
                  child: Text(
                    item.value.toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 4),
        // Área das barras
        SizedBox(
          height: maxBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: items.map((item) {
              final barHeight = (item.value / effectiveMax) * maxBarHeight;
              final barColor = item.color ?? defaultColor;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: barWidth,
                height: barHeight > 0 ? barHeight : 4,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Área dos rótulos
        SizedBox(
          height: labelAreaHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              return SizedBox(
                width: barWidth,
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Widget de gráfico de barras horizontais.
class HorizontalBarChartWidget extends StatelessWidget {
  /// Lista de itens do gráfico.
  final List<BarChartItem> items;

  /// Altura de cada barra.
  final double barHeight;

  /// Cor padrão das barras.
  final Color defaultColor;

  /// Se deve mostrar os valores.
  final bool showValues;

  const HorizontalBarChartWidget({
    super.key,
    required this.items,
    this.barHeight = 24,
    this.defaultColor = Colors.blue,
    this.showValues = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Sem dados disponíveis'),
      );
    }

    // Encontra o valor máximo para escalar as barras
    final maxValue = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxValue > 0 ? maxValue : 1;

    return Column(
      children: items.map((item) {
        final barWidthPercent = item.value / effectiveMax;
        final barColor = item.color ?? defaultColor;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Rótulo
              SizedBox(
                width: 100,
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Barra
              Expanded(
                child: Stack(
                  children: [
                    // Background
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(barHeight / 2),
                      ),
                    ),
                    // Barra de valor
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.centerLeft,
                      widthFactor: barWidthPercent > 0 ? barWidthPercent : 0.02,
                      child: Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              barColor,
                              barColor.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(barHeight / 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Valor
              if (showValues)
                SizedBox(
                  width: 40,
                  child: Text(
                    item.value.toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.end,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Widget animado que permite animar widthFactor.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final AlignmentGeometry alignment;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    required this.widthFactor,
    required this.alignment,
    required this.child,
  });

  @override
  AnimatedFractionallySizedBoxState createState() =>
      AnimatedFractionallySizedBoxState();
}

class AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: widget.alignment,
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}

