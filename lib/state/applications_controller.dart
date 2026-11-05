import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:piste/models/job_application.dart';

/// Owns the job applications and tells listeners when they change.
class ApplicationsController extends ChangeNotifier {
  ApplicationsController([List<JobApplication> initial = const []])
    : _applications = [...initial],
      _lastId = initial.fold(0, (highest, a) => math.max(highest, a.id ?? 0));

  final List<JobApplication> _applications;

  /// Highest id ever given out; only grows, so ids are never reused.
  int _lastId;

  /// Read-only view: changes must go through [save] and [delete].
  List<JobApplication> get applications => List.unmodifiable(_applications);

  /// The application with this id, or `null` if it no longer exists.
  JobApplication? byId(int id) =>
      _applications.where((a) => a.id == id).firstOrNull;

  /// Creates the application if it has no id, replaces it otherwise.
  Future<void> save(JobApplication application) async {
    final id = application.id;
    if (id == null) {
      _applications.add(application.withId(_nextId()));
    } else {
      final index = _applications.indexWhere((a) => a.id == id);
      if (index == -1) throw StateError('No application with id $id.');
      _applications[index] = application;
    }
    notifyListeners();
  }

  /// Removes the application; throws if it does not exist.
  Future<void> delete(int id) async {
    final before = _applications.length;
    _applications.removeWhere((a) => a.id == id);
    if (_applications.length == before) {
      throw StateError('No application with id $id.');
    }
    notifyListeners();
  }

  int _nextId() => ++_lastId;
}
