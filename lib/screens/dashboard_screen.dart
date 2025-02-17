import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'add_client_screen.dart';
import 'clients_screen.dart';
import 'connect_screen.dart';
import 'schedules_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final DatabaseService _dbService = DatabaseService.instance;
  final SyncService _syncService = SyncService.instance;
  List<Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _syncClients();
  }

  Future<void> _loadClients() async {
    try {
      setState(() => _isLoading = true);
      final clients = await _dbService.getAllClients();
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading clients: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading clients: $e')),
      );
    }
  }

  Future<void> _syncClients() async {
    try {
      await _syncService.syncPendingChanges();
      _loadClients(); // Reload clients after sync
    } catch (e) {
      print('Error syncing clients: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing clients: $e')),
      );
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Calculate statistics
    final totalRooms = _clients.length;
    final connectedUsers = _clients.where((c) => c.isActive).length;
    final disconnectedUsers = _clients.where((c) => !c.isActive).length;

    return RefreshIndicator(
      onRefresh: _loadClients,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Rooms',
                      totalRooms.toString(),
                      Icons.apartment,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Connected Users',
                      connectedUsers.toString(),
                      Icons.wifi,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Disconnected Users',
                      disconnectedUsers.toString(),
                      Icons.wifi_off,
                      Colors.red,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Sync Status',
                      '${_clients.where((c) => c.syncStatus == 'synced').length}/$totalRooms',
                      Icons.sync,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              // Recent Clients List
              ..._clients.take(5).map((client) => Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    client.isActive ? Icons.wifi : Icons.wifi_off,
                    color: client.isActive ? Colors.green : Colors.red,
                  ),
                  title: Text(client.fullName),
                  subtitle: Text('Room: ${client.roomNumber}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Expires: ${client.expirationDate.toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        client.syncStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: client.syncStatus == 'synced' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
              if (_clients.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No clients found. Add some clients to get started.'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Clients';
      case 2:
        return 'Connect';
      case 3:
        return 'Schedules';
      case 4:
        return 'Settings';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_selectedIndex)),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: _syncClients,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadClients();
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardContent(),
          ClientsScreen(), // Use dedicated ClientsScreen
          ConnectScreen(),
          SchedulesScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: 'Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
