import 'package:piste/models/job_application.dart';

/// Where job applications are stored. Every method throws a
/// `StorageException` on failure, and nothing else.
abstract interface class JobApplicationRepository {
  /// Every application, most recently updated first.
  Future<List<JobApplication>> fetchAll();

  /// Stores a new application (without id) and returns it with its new id.
  Future<JobApplication> insert(JobApplication application);

  /// Replaces the stored application with the same id; fails if none exists.
  Future<void> update(JobApplication application);

  /// Fails if no application has this id.
  Future<void> delete(int id);

  /// Releases the storage. The repository must not be used afterwards.
  Future<void> close();
}
