import 'package:piste/models/job_application.dart';

/// Figures shown on the home and statistics screens, computed once from the
/// full list, never from a filtered one (F18).
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

  /// Between 0 and 1. Zero when there is no application, instead of the
  /// `NaN` that `0 / 0` gives on doubles (F19).
  double share(ApplicationStatus status) =>
      total == 0 ? 0 : count(status) / total;

  /// [share] as a whole percentage, for display. The rounded values may not
  /// add up to exactly 100.
  int percent(ApplicationStatus status) => (share(status) * 100).round();
}
