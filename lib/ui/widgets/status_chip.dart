import 'package:flutter/material.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/theme/app_theme.dart';

/// Colored pill showing an application status.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.piste.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
