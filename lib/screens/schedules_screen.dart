import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({Key? key}) : super(key: key);

  @override
  _SchedulesScreenState createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  late Future<List<Client>> _clientsFuture;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshSchedules();
  }

  void _refreshSchedules() {
    setState(() {
      _clientsFuture = DatabaseService.instance.getAllClients();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Schedules for ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final clients = snapshot.data ?? [];
                final expiringClients = clients.where((client) {
                  return DateFormat('yyyy-MM-dd').format(client.expirationDate) ==
                      DateFormat('yyyy-MM-dd').format(_selectedDate);
                }).toList();

                if (expiringClients.isEmpty) {
                  return const Center(
                    child: Text('No schedules for this date'),
                  );
                }

                return ListView.builder(
                  itemCount: expiringClients.length,
                  itemBuilder: (context, index) {
                    final client = expiringClients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.event),
                        ),
                        title: Text(client.fullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Username: ${client.username}'),
                            Text('Plan: ${client.plan}'),
                            Text(
                              'Expiration: ${DateFormat('MMM dd, yyyy').format(client.expirationDate)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            // TODO: Implement notification settings
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add schedule functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
