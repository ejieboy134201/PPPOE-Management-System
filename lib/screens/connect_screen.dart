import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/database_service.dart';
import 'add_client_screen.dart';

class ConnectScreen extends StatefulWidget {
  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _dbService = DatabaseService.instance;
  List<Client> _clients = [];
  String? _selectedRoomNumber;
  String? _selectedPlan;
  bool _isConnected = true;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = true;
  final List<String> _plans = ['Plan 500', 'Plan 900', 'Plan 1200'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          // Automatically set toDate to 30 days after fromDate
          _toDate = picked.add(const Duration(days: 30));
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedRoomNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a room number')),
      );
      return;
    }

    try {
      // Find the client with the selected room number
      final client = _clients.firstWhere(
        (c) => c.roomNumber == _selectedRoomNumber,
      );

      // Update client status
      final updatedClient = client.copyWith(
        isActive: !client.isActive, // Toggle connection status
        plan: _selectedPlan ?? client.plan,
        lastModified: DateTime.now(),
        syncStatus: 'pending',
      );

      await _dbService.updateClient(updatedClient);
      _loadClients(); // Refresh the list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            client.isActive
                ? 'Client disconnected successfully'
                : 'Client connected successfully',
          ),
        ),
      );

      // Reset selection
      setState(() {
        _selectedRoomNumber = null;
        _selectedPlan = null;
      });
    } catch (e) {
      print('Error updating client connection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating client connection: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Connect/Disconnect'),
              Tab(text: 'Installation'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Connect/Disconnect Tab
          _buildConnectDisconnectTab(),
          // Add Client Tab
          AddClientScreen(),
        ],
      ),
    );
  }

  Widget _buildConnectDisconnectTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Room Number Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRoomNumber,
                  decoration: InputDecoration(labelText: 'Room Number'),
                  items: _clients.map((client) {
                    return DropdownMenuItem(
                      value: client.roomNumber,
                      child: Text('${client.roomNumber} - ${client.fullName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoomNumber = value;
                      // Find selected client and update UI accordingly
                      if (value != null) {
                        final client = _clients.firstWhere(
                          (c) => c.roomNumber == value,
                        );
                        _selectedPlan = client.plan;
                        _isConnected = client.isActive;
                      }
                    });
                  },
                ),
                SizedBox(height: 16),

                // Plan Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedPlan,
                  decoration: InputDecoration(labelText: 'Plan'),
                  items: _plans.map((plan) {
                    return DropdownMenuItem(
                      value: plan,
                      child: Text(plan),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlan = value;
                    });
                  },
                ),
                SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(_isConnected ? 'Disconnect Client' : 'Connect Client'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.red : Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
  }
}
