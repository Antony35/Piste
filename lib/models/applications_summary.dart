import 'package:piste/models/job_application.dart';

/// Figures shown on the home screen, computed once from the full list.
class ApplicationsSummary {
  const ApplicationsSummary._({
    required this.total,
    required this.active,
    required this.createdLastWeek,
    required this.followUpsDue,
    required this.byStatus,
    required this.recent,
  });

  factory ApplicationsSummary.from(
    List<JobApplication> applications,
    DateTime now, {
    int recentCount = 3,
  }) {
    final weekAgo = now.subtract(const Duration(days: 7));
    final byStatus = {for (final status in ApplicationStatus.values) status: 0};
    for (final application in applications) {
      byStatus[application.status] = byStatus[application.status]! + 1;
    }

    return ApplicationsSummary._(
      total: applications.length,
      active: applications.where((a) => !a.status.isClosed).length,
      createdLastWeek: applications
          .where((a) => a.createdAt.isAfter(weekAgo))
          .length,
      followUpsDue: applications.where((a) => a.needsFollowUp(now)).length,
      byStatus: Map.unmodifiable(byStatus),
      recent: List.unmodifiable(
        (applications.toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
            .take(recentCount),
      ),
    );
  }

  final int total;

  /// Not closed yet (neither offer nor rejected).
  final int active;
  final int createdLastWeek;
  final int followUpsDue;

  /// Count for every status, including those with zero.
  final Map<ApplicationStatus, int> byStatus;

  /// Most recently updated first.
  final List<JobApplication> recent;

  int count(ApplicationStatus status) => byStatus[status]!;
}
