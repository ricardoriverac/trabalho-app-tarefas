/// Widget de anel de progresso circular.
///
/// Exibe um indicador de progresso circular com texto central.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widget de anel de progresso animado.
class ProgressRingWidget extends StatefulWidget {
  /// Progresso de 0.0 a 1.0.
  final double progress;

  /// Tamanho do widget.
  final double size;

  /// Espessura do anel.
  final double strokeWidth;

  /// Cor do progresso.
  final Color progressColor;

  /// Cor do fundo do anel.
  final Color? backgroundColor;

  /// Widget central (ex: texto de porcentagem).
  final Widget? center;

  /// Se deve mostrar a porcentagem no centro.
  final bool showPercentage;

  /// Duração da animação.
  final Duration animationDuration;

  const ProgressRingWidget({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    this.progressColor = Colors.blue,
    this.backgroundColor,
    this.center,
    this.showPercentage = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<ProgressRingWidget> createState() => _ProgressRingWidgetState();
}

class _ProgressRingWidgetState extends State<ProgressRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final percentage = (_animation.value * 100).toInt();
          return Stack(
            alignment: Alignment.center,
            children: [
              // Anel de fundo
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: bgColor,
                ),
              ),
              // Anel de progresso
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  color: widget.progressColor,
                  hasGradient: true,
                ),
              ),
              // Centro
              widget.center ??
                  (widget.showPercentage
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percentage%',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: widget.progressColor,
                                  ),
                            ),
                            Text(
                              'concluído',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }
}

/// Painter customizado para desenhar o anel.
class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final bool hasGradient;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    this.hasGradient = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (hasGradient) {
      paint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          color.withValues(alpha: 0.3),
          color,
        ],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      paint.color = color;
    }

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Começa do topo
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Widget de múltiplos anéis concêntricos.
class MultiProgressRingWidget extends StatelessWidget {
  /// Lista de itens de progresso.
  final List<ProgressRingItem> items;

  /// Tamanho do widget.
  final double size;

  /// Espessura de cada anel.
  final double strokeWidth;

  /// Espaçamento entre anéis.
  final double spacing;

  const MultiProgressRingWidget({
    super.key,
    required this.items,
    this.size = 150,
    this.strokeWidth = 10,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < items.length; i++)
            ProgressRingWidget(
              progress: items[i].progress,
              size: size - (i * (strokeWidth + spacing) * 2),
              strokeWidth: strokeWidth,
              progressColor: items[i].color,
              showPercentage: false,
            ),
        ],
      ),
    );
  }
}

/// Item de progresso para MultiProgressRingWidget.
class ProgressRingItem {
  final double progress;
  final Color color;
  final String label;

  const ProgressRingItem({
    required this.progress,
    required this.color,
    required this.label,
  });
}

