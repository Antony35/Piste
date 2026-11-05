import 'dart:async';
import 'dart:math' as math;

import 'package:piste/data/job_application_repository.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/job_application.dart';

/// In-memory repository for tests. Never touches SQLite, and can simulate a
/// failing or slow storage.
class FakeJobApplicationRepository implements JobApplicationRepository {
  FakeJobApplicationRepository([List<JobApplication> initial = const []])
    : _rows = [...initial],
      _lastId = initial.fold(0, (highest, a) => math.max(highest, a.id ?? 0));

  final List<JobApplication> _rows;

  /// Only grows, like SQLite's AUTOINCREMENT: ids are never reused.
  int _lastId;

  bool failReads = false;
  bool failWrites = false;

  /// When set, every write waits for it to complete, like a slow disk.
  Completer<void>? writeGate;

  /// Number of insert, update and delete calls, failed ones included.
  int writes = 0;
  bool closed = false;

  @override
  Future<List<JobApplication>> fetchAll() async {
    if (failReads) throw const StorageException('Simulated read failure.');
    return [..._rows]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<JobApplication> insert(JobApplication application) async {
    await _write();
    final created = application.withId(++_lastId);
    _rows.add(created);
    return created;
  }

  @override
  Future<void> update(JobApplication application) async {
    await _write();
    _rows[_indexOf(application.id)] = application;
  }

  @override
  Future<void> delete(int id) async {
    await _write();
    _rows.removeAt(_indexOf(id));
  }

  @override
  Future<void> close() async => closed = true;

  Future<void> _write() async {
    writes++;
    await writeGate?.future;
    if (failWrites) throw const StorageException('Simulated write failure.');
  }

  int _indexOf(int? id) {
    final index = _rows.indexWhere((a) => a.id == id);
    if (index == -1) throw StorageException('No application with id $id.');
    return index;
  }
}
