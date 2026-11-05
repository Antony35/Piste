import 'package:piste/models/job_application.dart';

/// Search text and status chosen on the applications tab (F7, F8).
///
/// Immutable: each change gives a new filter.
class ApplicationFilter {
  const ApplicationFilter({this.query = '', this.status});

  /// As typed. Spaces around it and case are ignored when matching.
  final String query;

  /// `null` means every status (the « Toutes » chip).
  final ApplicationStatus? status;

  String get _needle => query.trim().toLowerCase();

  /// Whether some applications may be hidden.
  bool get isActive => _needle.isNotEmpty || status != null;

  ApplicationFilter withQuery(String query) =>
      ApplicationFilter(query: query, status: status);

  ApplicationFilter withStatus(ApplicationStatus? status) =>
      ApplicationFilter(query: query, status: status);

  /// Search and status must both match.
  bool matches(JobApplication application) {
    if (status != null && application.status != status) return false;
    final needle = _needle;
    return needle.isEmpty ||
        application.company.toLowerCase().contains(needle) ||
        application.position.toLowerCase().contains(needle);
  }

  /// The matching applications, most recently updated first (F6).
  List<JobApplication> apply(List<JobApplication> applications) =>
      List.unmodifiable(
        applications.where(matches).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
      );
}
