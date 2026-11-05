/// Stages of a job application, in order of progress.
enum ApplicationStatus {
  sent('Envoyée'),
  inProgress('En cours'),
  interview('Entretien'),
  offer('Offre'),
  rejected('Refusée');

  const ApplicationStatus(this.label);

  /// Text shown to the user.
  final String label;

  /// A closed application expects nothing more: no follow-up, no answer.
  bool get isClosed => this == offer || this == rejected;

  /// Reads a stored value. Unknown or missing values fall back to [sent]
  /// instead of throwing (rule D1).
  static ApplicationStatus fromName(String? name) =>
      values.asNameMap()[name] ?? sent;
}

/// A job application sent to a company.
class JobApplication {
  const JobApplication({
    this.id,
    required this.company,
    required this.position,
    this.status = ApplicationStatus.sent,
    this.appliedOn,
    this.nextFollowUp,
    this.url,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Assigned by the database on first save; `null` before that.
  final int? id;
  final String company;
  final String position;
  final ApplicationStatus status;
  final DateTime? appliedOn;
  final DateTime? nextFollowUp;
  final String? url;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Same application with the identifier assigned by storage.
  JobApplication withId(int id) => JobApplication(
    id: id,
    company: company,
    position: position,
    status: status,
    appliedOn: appliedOn,
    nextFollowUp: nextFollowUp,
    url: url,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Due for a follow-up when its date is reached and the application is
  /// not closed (rule D3). Compares calendar days, not times.
  bool needsFollowUp(DateTime now) {
    final followUp = nextFollowUp;
    if (followUp == null || status.isClosed) return false;
    return !_day(followUp).isAfter(_day(now));
  }

  /// Row ready for `sqflite`: text, integers or `null` only.
  ///
  /// Dates are ISO 8601 strings. The status is stored by its `name`, never
  /// its `label`, so rewording a label cannot break saved data.
  Map<String, Object?> toDatabase() => {
    if (id != null) 'id': id,
    'company': company,
    'position': position,
    'status': status.name,
    'applied_on': appliedOn?.toIso8601String(),
    'next_follow_up': nextFollowUp?.toIso8601String(),
    'url': url,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Throws if a required column is missing or malformed; the repository
  /// turns that into a storage error.
  factory JobApplication.fromDatabase(Map<String, Object?> row) =>
      JobApplication(
        id: row['id'] as int?,
        company: row['company'] as String,
        position: row['position'] as String,
        status: ApplicationStatus.fromName(row['status'] as String?),
        appliedOn: _dateOrNull(row['applied_on']),
        nextFollowUp: _dateOrNull(row['next_follow_up']),
        url: row['url'] as String?,
        notes: row['notes'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );

  static DateTime? _dateOrNull(Object? value) =>
      value == null ? null : DateTime.parse(value as String);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}
