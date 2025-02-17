import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import '../models/client.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  final DatabaseService _dbService = DatabaseService.instance;
  final SupabaseService _supabaseService = SupabaseService.instance;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _autoSync = true;

  SyncService._init() {
    _setupAutoSync();
  }

  void _setupAutoSync() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (_autoSync && result != ConnectivityResult.none) {
        syncPendingChanges();
      }
    });

    // Set up periodic sync every 5 minutes
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (_autoSync) {
        syncPendingChanges();
      }
    });
  }

  Future<void> setAutoSync(bool value) async {
    _autoSync = value;
    if (value) {
      syncPendingChanges();
    }
  }

  Future<void> forceSyncNow() async {
    await syncPendingChanges();
  }

  Future<void> syncPendingChanges() async {
    try {
      if (!await hasInternetConnection()) {
        print('No internet connection available for sync');
        return;
      }

      final pendingClients = await _dbService.getPendingSyncClients();
      print('Found ${pendingClients.length} clients pending sync');

      for (final client in pendingClients) {
        try {
          await _supabaseService.upsertClient(client);
          // Create a new client instance with updated sync status
          final updatedClient = Client(
            id: client.id,
            fullName: client.fullName,
            username: client.username,
            password: client.password,
            wifiName: client.wifiName,
            wifiPassword: client.wifiPassword,
            roomNumber: client.roomNumber,
            contactNumber: client.contactNumber,
            address: client.address,
            plan: client.plan,
            installationDate: client.installationDate,
            expirationDate: client.expirationDate,
            lastSync: DateTime.now(),
            lastModified: client.lastModified,
            syncStatus: 'synced',
            isActive: client.isActive,
          );
          await _dbService.updateClient(updatedClient);
          print('Successfully synced client: ${client.id}');
        } catch (e) {
          print('Error syncing client ${client.id}: $e');
          // Don't rethrow here to allow other clients to sync
        }
      }
    } catch (e) {
      print('Error during sync process: $e');
      rethrow;
    }
  }

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}
