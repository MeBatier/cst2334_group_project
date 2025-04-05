// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $MaintenanceDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $MaintenanceDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $MaintenanceDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<MaintenanceDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorMaintenanceDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $MaintenanceDatabaseBuilderContract databaseBuilder(String name) =>
      _$MaintenanceDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $MaintenanceDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$MaintenanceDatabaseBuilder(null);
}

class _$MaintenanceDatabaseBuilder
    implements $MaintenanceDatabaseBuilderContract {
  _$MaintenanceDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $MaintenanceDatabaseBuilderContract addMigrations(
      List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $MaintenanceDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<MaintenanceDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$MaintenanceDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$MaintenanceDatabase extends MaintenanceDatabase {
  _$MaintenanceDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MaintenanceDao? _maintenanceDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `MaintenanceRecord` (`id` INTEGER NOT NULL, `vehicleName` TEXT NOT NULL, `vehicleType` TEXT NOT NULL, `serviceType` TEXT NOT NULL, `serviceDate` TEXT NOT NULL, `mileage` TEXT NOT NULL, `cost` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MaintenanceDao get maintenanceDao {
    return _maintenanceDaoInstance ??=
        _$MaintenanceDao(database, changeListener);
  }
}

class _$MaintenanceDao extends MaintenanceDao {
  _$MaintenanceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _maintenanceRecordInsertionAdapter = InsertionAdapter(
            database,
            'MaintenanceRecord',
            (MaintenanceRecord item) => <String, Object?>{
                  'id': item.id,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                }),
        _maintenanceRecordUpdateAdapter = UpdateAdapter(
            database,
            'MaintenanceRecord',
            ['id'],
            (MaintenanceRecord item) => <String, Object?>{
                  'id': item.id,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                }),
        _maintenanceRecordDeletionAdapter = DeletionAdapter(
            database,
            'MaintenanceRecord',
            ['id'],
            (MaintenanceRecord item) => <String, Object?>{
                  'id': item.id,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MaintenanceRecord> _maintenanceRecordInsertionAdapter;

  final UpdateAdapter<MaintenanceRecord> _maintenanceRecordUpdateAdapter;

  final DeletionAdapter<MaintenanceRecord> _maintenanceRecordDeletionAdapter;

  @override
  Future<List<MaintenanceRecord>> getAllRecords() async {
    return _queryAdapter.queryList('SELECT * FROM MaintenanceRecord',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(
            row['id'] as int,
            row['vehicleName'] as String,
            row['vehicleType'] as String,
            row['serviceType'] as String,
            row['serviceDate'] as String,
            row['mileage'] as String,
            row['cost'] as String));
  }

  @override
  Future<void> insertRecord(MaintenanceRecord record) async {
    await _maintenanceRecordInsertionAdapter.insert(
        record, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRecord(MaintenanceRecord record) async {
    await _maintenanceRecordUpdateAdapter.update(
        record, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecord(MaintenanceRecord record) async {
    await _maintenanceRecordDeletionAdapter.delete(record);
  }
}
