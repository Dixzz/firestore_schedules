// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revent.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PersonDao? _personDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `REvent` (`title` TEXT NOT NULL, `desc` TEXT NOT NULL, `event` INTEGER NOT NULL, `edit` INTEGER NOT NULL, `priority` INTEGER NOT NULL, PRIMARY KEY (`title`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PersonDao get personDao {
    return _personDaoInstance ??= _$PersonDao(database, changeListener);
  }
}

class _$PersonDao extends PersonDao {
  _$PersonDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _rEventInsertionAdapter = InsertionAdapter(
            database,
            'REvent',
            (REvent item) => <String, Object?>{
                  'title': item.title,
                  'desc': item.desc,
                  'event': _dateTimeConverter.encode(item.event),
                  'edit': item.edit ? 1 : 0,
                  'priority': item.priority
                },
            changeListener),
        _rEventUpdateAdapter = UpdateAdapter(
            database,
            'REvent',
            ['title'],
            (REvent item) => <String, Object?>{
                  'title': item.title,
                  'desc': item.desc,
                  'event': _dateTimeConverter.encode(item.event),
                  'edit': item.edit ? 1 : 0,
                  'priority': item.priority
                },
            changeListener),
        _rEventDeletionAdapter = DeletionAdapter(
            database,
            'REvent',
            ['title'],
            (REvent item) => <String, Object?>{
                  'title': item.title,
                  'desc': item.desc,
                  'event': _dateTimeConverter.encode(item.event),
                  'edit': item.edit ? 1 : 0,
                  'priority': item.priority
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<REvent> _rEventInsertionAdapter;

  final UpdateAdapter<REvent> _rEventUpdateAdapter;

  final DeletionAdapter<REvent> _rEventDeletionAdapter;

  @override
  Stream<List<REvent>> findAllPersons(
    DateTime start,
    DateTime end,
  ) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM REvent WHERE event between ?1 and ?2 ORDER BY event ASC',
        mapper: (Map<String, Object?> row) => REvent(
            row['title'] as String,
            row['desc'] as String,
            _dateTimeConverter.decode(row['event'] as int),
            row['priority'] as int,
            (row['edit'] as int) != 0),
        arguments: [
          _dateTimeConverter.encode(start),
          _dateTimeConverter.encode(end)
        ],
        queryableName: 'REvent',
        isView: false);
  }

  @override
  Stream<List<REvent>> findAllPersonsFiltered(
    int priority,
    DateTime start,
    DateTime end,
  ) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM REvent WHERE priority = ?1 AND event between ?2 and ?3  ORDER BY event ASC',
        mapper: (Map<String, Object?> row) => REvent(
            row['title'] as String,
            row['desc'] as String,
            _dateTimeConverter.decode(row['event'] as int),
            row['priority'] as int,
            (row['edit'] as int) != 0),
        arguments: [
          priority,
          _dateTimeConverter.encode(start),
          _dateTimeConverter.encode(end)
        ],
        queryableName: 'REvent',
        isView: false);
  }

  @override
  Future<void> insertItem(REvent person) async {
    await _rEventInsertionAdapter.insert(person, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateItem(REvent person) async {
    await _rEventUpdateAdapter.update(person, OnConflictStrategy.replace);
  }

  @override
  Future<void> deletePeople(List<REvent> people) async {
    await _rEventDeletionAdapter.deleteList(people);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
