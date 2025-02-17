import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/client.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('clients.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize FFI
    sqfliteFfiInit();
    
    // Get the application documents directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocDir.path, filePath);
    
    final databaseFactory = databaseFactoryFfi;
    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        wifi_name TEXT NOT NULL,
        wifi_password TEXT NOT NULL,
        room_number TEXT NOT NULL,
        contact_number TEXT NOT NULL,
        address TEXT NOT NULL,
        plan TEXT NOT NULL,
        installation_date TEXT NOT NULL,
        expiration_date TEXT NOT NULL,
        last_sync TEXT NOT NULL,
        last_modified TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<int> createClient(Client client) async {
    try {
      final db = await database;
      final data = {
        'full_name': client.fullName,
        'username': client.username,
        'password': client.password,
        'wifi_name': client.wifiName,
        'wifi_password': client.wifiPassword,
        'room_number': client.roomNumber,
        'contact_number': client.contactNumber,
        'address': client.address,
        'plan': client.plan,
        'installation_date': client.installationDate.toIso8601String(),
        'expiration_date': client.expirationDate.toIso8601String(),
        'last_sync': client.lastSync.toIso8601String(),
        'last_modified': client.lastModified.toIso8601String(),
        'sync_status': client.syncStatus,
        'is_active': client.isActive ? 1 : 0,
      };
      
      final id = await db.insert('clients', data);
      print('Created client with ID: $id');
      return id;
    } catch (e) {
      print('Error creating client: $e');
      rethrow;
    }
  }

  Future<List<Client>> getAllClients() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        orderBy: 'last_modified DESC',
      );
      
      print('Found ${maps.length} clients in database');
      return List.generate(maps.length, (i) {
        try {
          return Client.fromMap(maps[i]);
        } catch (e) {
          print('Error parsing client ${maps[i]['id']}: $e');
          rethrow;
        }
      });
    } catch (e) {
      print('Error getting all clients: $e');
      rethrow;
    }
  }

  Future<int> updateClient(Client client) async {
    try {
      final db = await database;
      final data = {
        'full_name': client.fullName,
        'username': client.username,
        'password': client.password,
        'wifi_name': client.wifiName,
        'wifi_password': client.wifiPassword,
        'room_number': client.roomNumber,
        'contact_number': client.contactNumber,
        'address': client.address,
        'plan': client.plan,
        'installation_date': client.installationDate.toIso8601String(),
        'expiration_date': client.expirationDate.toIso8601String(),
        'last_sync': client.lastSync?.toIso8601String(),
        'last_modified': client.lastModified.toIso8601String(),
        'sync_status': client.syncStatus,
        'is_active': client.isActive ? 1 : 0,
      };
      
      return await db.update(
        'clients',
        data,
        where: 'id = ?',
        whereArgs: [client.id],
      );
    } catch (e) {
      print('Error updating client: $e');
      rethrow;
    }
  }

  Future<List<Client>> getPendingSyncClients() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'sync_status = ?',
        whereArgs: ['pending'],
      );
      return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
    } catch (e) {
      print('Error getting pending sync clients: $e');
      rethrow;
    }
  }

  Future<Client?> getClient(int id) async {
    final db = await database;
    final maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Client.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
