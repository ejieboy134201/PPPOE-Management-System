import '../config/supabase_config.dart';

class Client {
  final int? id;
  final String fullName;
  final String username;
  final String password;
  final String wifiName;
  final String wifiPassword;
  final String roomNumber;
  final String contactNumber;
  final String address;
  final String plan;
  final DateTime installationDate;
  final DateTime expirationDate;
  final DateTime lastSync;
  final DateTime lastModified;
  String syncStatus;
  bool isActive;

  Client({
    this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.wifiName,
    required this.wifiPassword,
    required this.roomNumber,
    required this.contactNumber,
    required this.address,
    required this.plan,
    required this.installationDate,
    required this.expirationDate,
    DateTime? lastSync,
    DateTime? lastModified,
    this.syncStatus = 'pending',
    this.isActive = true,
  }) : this.lastSync = lastSync ?? DateTime.now(),
       this.lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'password': password,
      'wifi_name': wifiName,
      'wifi_password': wifiPassword,
      'room_number': roomNumber,
      'contact_number': contactNumber,
      'address': address,
      'plan': plan,
      'installation_date': installationDate.toIso8601String(),
      'expiration_date': expirationDate.toIso8601String(),
      'last_sync': lastSync.toIso8601String(),
      'last_modified': lastModified.toIso8601String(),
      'sync_status': syncStatus,
      'is_active': isActive,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      fullName: map['full_name'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      wifiName: map['wifi_name'] ?? '',
      wifiPassword: map['wifi_password'] ?? '',
      roomNumber: map['room_number'] ?? '',
      contactNumber: map['contact_number'] ?? '',
      address: map['address'] ?? '',
      plan: map['plan'] ?? '',
      installationDate: map['installation_date'] != null 
          ? DateTime.parse(map['installation_date']) 
          : DateTime.now(),
      expirationDate: map['expiration_date'] != null 
          ? DateTime.parse(map['expiration_date']) 
          : DateTime.now().add(const Duration(days: 30)),
      lastSync: map['last_sync'] != null 
          ? DateTime.parse(map['last_sync']) 
          : DateTime.now(),
      lastModified: map['last_modified'] != null 
          ? DateTime.parse(map['last_modified']) 
          : DateTime.now(),
      syncStatus: map['sync_status'] ?? 'pending',
      isActive: map['is_active'] == true || map['is_active'] == 1,
    );
  }

  Client copyWith({
    int? id,
    String? fullName,
    String? username,
    String? password,
    String? wifiName,
    String? wifiPassword,
    String? roomNumber,
    String? contactNumber,
    String? address,
    String? plan,
    DateTime? installationDate,
    DateTime? expirationDate,
    DateTime? lastSync,
    DateTime? lastModified,
    String? syncStatus,
    bool? isActive,
  }) {
    return Client(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      password: password ?? this.password,
      wifiName: wifiName ?? this.wifiName,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      roomNumber: roomNumber ?? this.roomNumber,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      plan: plan ?? this.plan,
      installationDate: installationDate ?? this.installationDate,
      expirationDate: expirationDate ?? this.expirationDate,
      lastSync: lastSync ?? this.lastSync,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
      isActive: isActive ?? this.isActive,
    );
  }
}
