import 'package:flutter/material.dart';

/// Shown while the applications are being read.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(semanticsLabel: 'Chargement'),
  );
}

/// Shown when storage holds no application yet.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => _MessageView(
    icon: Icons.work_outline_rounded,
    title: 'Aucune candidature',
    body: 'Ajoutez votre première candidature pour suivre son avancement.',
    action: FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Ajouter une candidature'),
    ),
  );
}

/// Shown when applications exist but none matches the search (rule S2).
class NoResultsView extends StatelessWidget {
  const NoResultsView({super.key, required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => _MessageView(
    icon: Icons.search_off_rounded,
    title: 'Aucun résultat',
    body: 'Aucune candidature ne correspond à votre recherche.',
    action: FilledButton.tonalIcon(
      onPressed: onClear,
      icon: const Icon(Icons.close_rounded),
      label: const Text('Effacer la recherche'),
    ),
  );
}

/// Shown when reading failed. Displays [message] as given (rule S3).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _MessageView(
    icon: Icons.error_outline_rounded,
    iconColor: Theme.of(context).colorScheme.error,
    title: message,
    // Read out by screen readers as soon as it appears.
    liveRegion: true,
    action: FilledButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Réessayer'),
    ),
  );
}

/// Centered icon, title, optional text and one button. Scrolls when the
/// text is large rather than overflowing.
class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.action,
    this.body,
    this.iconColor,
    this.liveRegion = false,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? body;
  final Widget action;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: 48,
                color: iconColor ?? scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: liveRegion,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (body case final body?) ...[
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),
            action,
          ],
        ),
      ),
    );
  }
}
