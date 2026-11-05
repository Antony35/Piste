import 'package:path/path.dart' as p;
import 'package:piste/data/job_application_repository.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/job_application.dart';
import 'package:sqflite/sqflite.dart';

/// Stores applications in `piste.db`, in the app's private database folder.
///
/// The database opens on first use, so a failure to open is reported like
/// any other read error and can be retried.
class SqliteJobApplicationRepository implements JobApplicationRepository {
  static const _fileName = 'piste.db';
  static const _table = 'job_applications';

  /// Raise by one with each schema change, and add the step to [_onUpgrade].
  static const _schemaVersion = 1;

  Database? _db;

  @override
  Future<List<JobApplication>> fetchAll() =>
      _run('read applications', (db) async {
        final rows = await db.query(_table, orderBy: 'updated_at DESC');
        return rows.map(JobApplication.fromDatabase).toList();
      });

  @override
  Future<JobApplication> insert(JobApplication application) {
    assert(application.id == null, 'insert() is for new applications only.');
    return _run('insert an application', (db) async {
      final id = await db.insert(_table, application.toDatabase());
      return application.withId(id);
    });
  }

  @override
  Future<void> update(JobApplication application) {
    final id = application.id;
    if (id == null) {
      throw ArgumentError.value(application, 'application', 'has no id');
    }
    return _run('update application $id', (db) async {
      final changed = await db.update(
        _table,
        application.toDatabase(),
        where: 'id = ?',
        whereArgs: [id],
      );
      if (changed == 0) throw StorageException('No application with id $id.');
    });
  }

  @override
  Future<void> delete(int id) => _run('delete application $id', (db) async {
    final deleted = await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    if (deleted == 0) throw StorageException('No application with id $id.');
  });

  @override
  Future<void> close() async {
    final db = _db;
    _db = null;
    await db?.close();
  }

  /// Opens the database if needed, runs [body], and turns every storage
  /// failure into a [StorageException].
  Future<T> _run<T>(String action, Future<T> Function(Database db) body) async {
    try {
      return await body(_db ??= await _open());
    } on StorageException {
      rethrow;
    } on DatabaseException catch (e) {
      throw StorageException('Could not $action.', e);
    } on FormatException catch (e) {
      // A stored date that is not ISO 8601.
      throw StorageException('Could not $action: malformed row.', e);
    } on TypeError catch (e) {
      // A required column is missing or has the wrong type.
      throw StorageException('Could not $action: malformed row.', e);
    }
  }

  static Future<Database> _open() async => openDatabase(
    p.join(await getDatabasesPath(), _fileName),
    version: _schemaVersion,
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );

  static Future<void> _onCreate(Database db, int version) => db.execute('''
    CREATE TABLE $_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      company TEXT NOT NULL,
      position TEXT NOT NULL,
      status TEXT NOT NULL,
      applied_on TEXT,
      next_follow_up TEXT,
      url TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  /// Brings an existing database from [oldVersion] to [newVersion], one step
  /// at a time. Version 1 is the first schema: nothing to migrate yet.
  ///
  /// Example for version 2:
  /// `if (oldVersion < 2) await db.execute('ALTER TABLE ... ADD COLUMN ...');`
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}
}
