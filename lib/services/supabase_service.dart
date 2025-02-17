import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  late final SupabaseClient _supabase;

  SupabaseService._init() {
    _supabase = Supabase.instance.client;
  }

  Future<void> upsertClient(Client client) async {
    try {
      // Check if username already exists
      final existingClients = await _supabase
          .from('clients')
          .select()
          .eq('username', client.username);
      
      if (existingClients.isNotEmpty) {
        // If client exists with this username but different ID, append a unique identifier
        final existingClient = existingClients[0];
        if (existingClient['id'] != client.id) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final uniqueUsername = '${client.username}_$timestamp';
          
          final data = client.toMap();
          data.remove('id');
          data['username'] = uniqueUsername;
          
          await _supabase
              .from('clients')
              .upsert(data)
              .select();
              
          print('Successfully upserted client with modified username: $uniqueUsername');
          return;
        }
      }
      
      // If no conflict, proceed with normal upsert
      final data = client.toMap();
      data.remove('id');
      
      await _supabase
          .from('clients')
          .upsert(data)
          .select();

      print('Successfully upserted client: ${client.username}');
    } catch (e) {
      print('Error upserting client: $e');
      rethrow;
    }
  }

  Future<List<Client>> getAllClients() async {
    try {
      final response = await _supabase
          .from('clients')
          .select();

      return (response as List<dynamic>)
          .map((json) => Client.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting clients from Supabase: $e');
      rethrow;
    }
  }
}
