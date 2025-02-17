import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  final SyncService _syncService = SyncService.instance;
  List<Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
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

  Future<void> _showClientDetails(Client client) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Client Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Full Name', client.fullName),
              _buildDetailItem('Room Number', client.roomNumber),
              _buildDetailItem('Username', client.username),
              _buildDetailItem('WiFi Name', client.wifiName),
              _buildDetailItem('Contact Number', client.contactNumber),
              _buildDetailItem('Address', client.address),
              _buildDetailItem('Plan', client.plan),
              _buildDetailItem('Installation Date', client.installationDate.toString().split(' ')[0]),
              _buildDetailItem('Expiration Date', client.expirationDate.toString().split(' ')[0]),
              _buildDetailItem('Status', client.isActive ? 'Connected' : 'Disconnected'),
              Divider(height: 20),
              Text('Connection History', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Installed: ${client.installationDate.toString().split(' ')[0]}'),
              Text('Expires: ${client.expirationDate.toString().split(' ')[0]}'),
              if (!client.isActive) Text('Disconnected: ${DateTime.now().toString().split(' ')[0]}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(Client client) async {
    final TextEditingController fullNameController = TextEditingController(text: client.fullName);
    final TextEditingController usernameController = TextEditingController(text: client.username);
    final TextEditingController passwordController = TextEditingController(text: client.password);
    final TextEditingController wifiNameController = TextEditingController(text: client.wifiName);
    final TextEditingController wifiPasswordController = TextEditingController(text: client.wifiPassword);
    final TextEditingController roomNumberController = TextEditingController(text: client.roomNumber);
    final TextEditingController contactNumberController = TextEditingController(text: client.contactNumber);
    final TextEditingController addressController = TextEditingController(text: client.address);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Client'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: wifiNameController,
                decoration: InputDecoration(labelText: 'WiFi Name'),
              ),
              TextField(
                controller: wifiPasswordController,
                decoration: InputDecoration(labelText: 'WiFi Password'),
              ),
              TextField(
                controller: roomNumberController,
                decoration: InputDecoration(labelText: 'Room Number'),
              ),
              TextField(
                controller: contactNumberController,
                decoration: InputDecoration(labelText: 'Contact Number'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Update'),
          ),
        ],
      ),
    );

    if (result == true) {
      final updatedClient = client.copyWith(
        fullName: fullNameController.text,
        username: usernameController.text,
        password: passwordController.text,
        wifiName: wifiNameController.text,
        wifiPassword: wifiPasswordController.text,
        roomNumber: roomNumberController.text,
        contactNumber: contactNumberController.text,
        address: addressController.text,
        lastModified: DateTime.now(),
        syncStatus: 'pending',
      );

      try {
        await _dbService.updateClient(updatedClient);
        _loadClients();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating client: $e')),
        );
      }
    }
  }

  Future<void> _deleteClient(Client client) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Client'),
        content: Text('Are you sure you want to delete ${client.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _dbService.deleteClient(client.id!);
        _loadClients();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting client: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadClients,
      child: _clients.isEmpty
          ? Center(
              child: Text('No clients found. Add some clients to get started.'),
            )
          : ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => _showClientDetails(client),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: client.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  client.fullName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(client),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteClient(client),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Room: ${client.roomNumber}'),
                                    Text('Username: ${client.username}'),
                                    Text('Plan: ${client.plan}'),
                                    Text(
                                      'Status: ${client.isActive ? "Connected" : "Disconnected"}',
                                      style: TextStyle(
                                        color: client.isActive ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Expires: ${client.expirationDate.toString().split(' ')[0]}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Sync: ${client.syncStatus}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: client.syncStatus == 'synced' ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
