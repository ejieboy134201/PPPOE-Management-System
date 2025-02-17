import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: Text('Dark Mode'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text('Database Management'),
              subtitle: Text('Export, import, or reset database'),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text('About'),
              subtitle: Text('PPPoE Network Manager v1.0.0'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'PPPoE Network Manager',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(Icons.router),
                  children: [
                    Text('A network management application for PPPoE clients.'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
