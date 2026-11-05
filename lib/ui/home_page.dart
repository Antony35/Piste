import 'package:flutter/material.dart';
import 'package:piste/models/applications_summary.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/format.dart';
import 'package:piste/ui/theme/app_theme.dart';
import 'package:piste/ui/widgets/application_tile.dart';

/// Home tab: greeting, summary card, counters and recent applications.
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.applications,
    required this.onSeeAll,
  });

  final List<JobApplication> applications;

  /// Opens the applications tab.
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final summary = ApplicationsSummary.from(applications, now);
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
      children: [
        Text(longDate(now), style: text.bodyMedium?.copyWith(color: muted)),
        const SizedBox(height: 2),
        Text(
          'Bonjour',
          style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _SummaryCard(summary: summary),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Counter(
                  icon: Icons.event_available_rounded,
                  value: summary.count(ApplicationStatus.interview),
                  label: 'Entretiens',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Counter(
                  icon: Icons.workspace_premium_rounded,
                  value: summary.count(ApplicationStatus.offer),
                  label: 'Offres',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Counter(
                  icon: Icons.notifications_active_rounded,
                  value: summary.followUpsDue,
                  label: 'À relancer',
                  highlight: summary.followUpsDue > 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Récentes',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: onSeeAll,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Tout voir'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final application in summary.recent) ...[
          ApplicationTile(
            key: ValueKey(application.id),
            application: application,
            now: now,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ApplicationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final piste = context.piste;
    final text = Theme.of(context).textTheme;

    return Card(
      color: piste.summaryCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A Row overflowed here with large text on small screens.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  'Candidatures en cours',
                  style: text.bodyMedium?.copyWith(
                    color: piste.onSummaryCardMuted,
                  ),
                ),
                if (summary.createdLastWeek > 0)
                  _Pill(text: '+${summary.createdLastWeek} cette semaine'),
              ],
            ),
            Text(
              '${summary.active}',
              style: text.displaySmall?.copyWith(
                color: piste.onSummaryCard,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _DistributionBar(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final piste = context.piste;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: piste.onSummaryCard.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: piste.onSummaryCard, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// One segment per status, proportional to its count.
class _DistributionBar extends StatelessWidget {
  const _DistributionBar({required this.summary});

  final ApplicationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final piste = context.piste;
    final present = ApplicationStatus.values
        .where((status) => summary.count(status) > 0)
        .toList();

    return Semantics(
      label: present.isEmpty
          ? 'Aucune candidature'
          : present.map((s) => '${summary.count(s)} ${s.label}').join(', '),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 8,
          child: present.isEmpty
              ? ColoredBox(color: piste.onSummaryCard.withValues(alpha: 0.18))
              : Row(
                  children: [
                    for (final status in present)
                      Expanded(
                        flex: summary.count(status),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          color: piste.summaryBar[status],
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
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
