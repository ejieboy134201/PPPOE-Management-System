import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/database_service.dart';

class AddClientScreen extends StatefulWidget {
  final Client? clientToEdit;

  const AddClientScreen({Key? key, this.clientToEdit}) : super(key: key);

  @override
  _AddClientScreenState createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService.instance;

  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _wifiNameController;
  late TextEditingController _wifiPasswordController;
  late TextEditingController _roomNumberController;
  late DateTime _installationDate;
  late DateTime _expirationDate;
  String _selectedPlan = 'Plan 500';

  final List<String> _plans = ['Plan 500', 'Plan 900', 'Plan 1200'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.clientToEdit?.fullName);
    _usernameController = TextEditingController(text: widget.clientToEdit?.username);
    _passwordController = TextEditingController(text: widget.clientToEdit?.password);
    _wifiNameController = TextEditingController(text: widget.clientToEdit?.wifiName);
    _wifiPasswordController = TextEditingController(text: widget.clientToEdit?.wifiPassword);
    _roomNumberController = TextEditingController(text: widget.clientToEdit?.roomNumber);
    _installationDate = widget.clientToEdit?.installationDate ?? DateTime.now();
    _expirationDate = widget.clientToEdit?.expirationDate ?? DateTime.now().add(Duration(days: 30));
    _selectedPlan = widget.clientToEdit?.plan ?? 'Plan 500';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _wifiNameController.dispose();
    _wifiPasswordController.dispose();
    _roomNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isInstallation) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInstallation ? _installationDate : _expirationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isInstallation) {
          _installationDate = picked;
        } else {
          _expirationDate = picked;
        }
      });
    }
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      try {
        final client = Client(
          id: widget.clientToEdit?.id,
          fullName: _fullNameController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          wifiName: _wifiNameController.text,
          wifiPassword: _wifiPasswordController.text,
          roomNumber: _roomNumberController.text,
          contactNumber: '', // Default empty string for now
          address: '', // Default empty string for now
          plan: _selectedPlan,
          installationDate: _installationDate,
          expirationDate: _expirationDate,
          lastSync: null,
          lastModified: DateTime.now(),
          syncStatus: 'pending',
          isActive: true,
        );

        if (widget.clientToEdit != null) {
          await _dbService.updateClient(client);
          Navigator.of(context).pop(true); // Return true to indicate successful update
        } else {
          await _dbService.createClient(client);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Client added successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear form
          _formKey.currentState!.reset();
          _fullNameController.clear();
          _usernameController.clear();
          _passwordController.clear();
          _wifiNameController.clear();
          _wifiPasswordController.clear();
          _roomNumberController.clear();

          // Navigate to dashboard using Navigator
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving client: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientToEdit != null ? 'Edit Client' : 'Add Client'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'PPPoE Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PPPoE username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'PPPoE Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PPPoE password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _wifiNameController,
                decoration: InputDecoration(
                  labelText: 'WiFi Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter WiFi name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _wifiPasswordController,
                decoration: InputDecoration(
                  labelText: 'WiFi Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter WiFi password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _roomNumberController,
                decoration: InputDecoration(
                  labelText: 'Room Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPlan,
                decoration: InputDecoration(
                  labelText: 'Plan',
                  border: OutlineInputBorder(),
                ),
                items: _plans.map((String plan) {
                  return DropdownMenuItem<String>(
                    value: plan,
                    child: Text(plan),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPlan = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Installation Date: ${_installationDate.toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text('Expiration Date: ${_expirationDate.toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveClient,
                child: Text(widget.clientToEdit != null ? 'Update Client' : 'Add Client'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
