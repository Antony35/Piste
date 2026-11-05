import 'package:flutter/material.dart';
import 'package:piste/models/applications_summary.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/theme/app_theme.dart';

/// Statistics tab: total, then count, share and bar for each status (F17).
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.applications});

  /// The full list, never the filtered one (F18).
  final List<JobApplication> applications;

  @override
  Widget build(BuildContext context) {
    final summary = ApplicationsSummary.from(applications, DateTime.now());
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              container: true,
              label: '${summary.total} candidatures au total',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: text.bodyMedium?.copyWith(color: muted)),
                  Text(
                    '${summary.total}',
                    style: text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                for (final status in ApplicationStatus.values)
                  _StatusRow(status: status, summary: summary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.status, required this.summary});

  final ApplicationStatus status;
  final ApplicationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.piste.of(status);
    final text = Theme.of(context).textTheme;
    final count = summary.count(status);
    // Narrow no-break space: French typography, and « % » never wraps alone.
    final percent = '${summary.percent(status)} %';

    // container: one node per row, so TalkBack reads each status apart.
    return Semantics(
      container: true,
      label: '${status.label} : $count, $percent',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(status.label, style: text.titleSmall)),
                Text(
                  '$count · $percent',
                  style: text.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: summary.share(status),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              color: colors.foreground,
              backgroundColor: colors.background,
            ),
          ],
        ),
      ),
    );
  }
}
