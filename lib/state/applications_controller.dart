import 'package:flutter/foundation.dart';
import 'package:piste/data/job_application_repository.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/job_application.dart';

/// The four states a screen fed by storage can show (spec section 5).
enum LoadState { loading, error, empty, success }

/// Owns the job applications and tells listeners when they change.
///
/// Call [load] once after creating it.
class ApplicationsController extends ChangeNotifier {
  ApplicationsController(this._repository);

  final JobApplicationRepository _repository;

  List<JobApplication> _applications = const [];
  bool _loading = true;
  String? _errorMessage;

  /// Read-only: changes must go through [save] and [delete].
  List<JobApplication> get applications => _applications;

  /// Shown as is by the error screen, which writes no message of its own.
  String? get errorMessage => _errorMessage;

  /// Derived from the fields above, so it can never contradict them.
  LoadState get state {
    if (_loading) return LoadState.loading;
    if (_errorMessage != null) return LoadState.error;
    return _applications.isEmpty ? LoadState.empty : LoadState.success;
  }

  /// The application with this id, or `null` if it no longer exists.
  JobApplication? byId(int id) =>
      _applications.where((a) => a.id == id).firstOrNull;

  /// Reads everything from storage. A failure becomes the error state, never
  /// an empty list (rule S1).
  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _applications = List.unmodifiable(await _repository.fetchAll());
    } on StorageException {
      _applications = const [];
      _errorMessage = 'Chargement impossible.';
    }
    _loading = false;
    notifyListeners();
  }

  /// Creates the application if it has no id, replaces it otherwise.
  ///
  /// Throws a [StorageException] on failure, leaving the list unchanged.
  Future<void> save(JobApplication application) async {
    if (application.id == null) {
      final created = await _repository.insert(application);
      _applications = List.unmodifiable([..._applications, created]);
    } else {
      await _repository.update(application);
      _applications = List.unmodifiable([
        for (final a in _applications) a.id == application.id ? application : a,
      ]);
    }
    notifyListeners();
  }

  /// Throws a [StorageException] on failure, leaving the list unchanged.
  Future<void> delete(int id) async {
    await _repository.delete(id);
    _applications = List.unmodifiable(_applications.where((a) => a.id != id));
    notifyListeners();
  }
}
