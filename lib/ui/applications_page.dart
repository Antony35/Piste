import 'package:flutter/material.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/widgets/application_tile.dart';

/// Full list of applications, most recently updated first.
class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key, required this.applications});

  final List<JobApplication> applications;

  @override
  Widget build(BuildContext context) {
    final sorted = applications.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final now = DateTime.now();

    return ListView.separated(
      // Extra bottom space keeps the last card clear of the floating button.
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final application = sorted[index];
        return ApplicationTile(
          key: ValueKey(application.id),
          application: application,
          now: now,
        );
      },
    );
  }
}
