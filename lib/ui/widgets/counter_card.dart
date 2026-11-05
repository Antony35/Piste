import 'package:flutter/material.dart';

/// A figure with its icon and label, as on the home and profile screens.
class CounterCard extends StatelessWidget {
  const CounterCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final int value;
  final String label;

  /// Draws the value in the action color, to signal something to do.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final accent = highlight ? scheme.secondary : scheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: Icon(icon, size: 20, color: accent)),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: highlight ? scheme.secondary : null,
              ),
            ),
            Text(
              label,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
