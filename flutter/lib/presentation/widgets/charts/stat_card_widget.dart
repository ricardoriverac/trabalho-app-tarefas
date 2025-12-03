/// Widget de card de estatística.
///
/// Exibe uma métrica com ícone, valor e descrição.
library;

import 'package:flutter/material.dart';

/// Card de estatística individual.
class StatCardWidget extends StatelessWidget {
  /// Título da estatística.
  final String title;

  /// Valor principal.
  final String value;

  /// Subtítulo ou descrição.
  final String? subtitle;

  /// Ícone.
  final IconData icon;

  /// Cor do ícone e destaques.
  final Color color;

  /// Se o card deve ter background colorido.
  final bool filled;

  /// Callback ao tocar.
  final VoidCallback? onTap;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color = Colors.blue,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: filled ? 0 : 2,
      color: filled ? color.withValues(alpha: 0.15) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: filled
            ? BorderSide(color: color.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone e título
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: filled
                          ? color.withValues(alpha: 0.2)
                          : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Valor principal
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: filled ? color : null,
                ),
              ),
              // Subtítulo
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de estatística compacto (horizontal).
class CompactStatCardWidget extends StatelessWidget {
  /// Título da estatística.
  final String title;

  /// Valor principal.
  final String value;

  /// Ícone.
  final IconData icon;

  /// Cor do ícone.
  final Color color;

  const CompactStatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card de streak com fogo animado.
class StreakCardWidget extends StatelessWidget {
  /// Dias de streak atual.
  final int currentStreak;

  /// Melhor streak.
  final int bestStreak;

  const StreakCardWidget({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnFire = currentStreak >= 3;
    final fireColor = isOnFire ? Colors.orange : Colors.grey;

    return Card(
      elevation: 0,
      color: fireColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: fireColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Ícone de fogo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fireColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOnFire
                    ? Icons.local_fire_department
                    : Icons.whatshot_outlined,
                size: 32,
                color: fireColor,
              ),
            ),
            const SizedBox(width: 16),
            // Informações do streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sequência atual',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$currentStreak',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: fireColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentStreak == 1 ? 'dia' : 'dias',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Melhor streak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 20,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$bestStreak',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'recorde',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}

