class SupabaseConfig {
  // Get these values from your Supabase project settings
  // Project URL: Settings -> API -> Project URL
  static const String url = 'https://bqmgppgnhbothmvudxwz.supabase.co';
  
  // Anon Key: Settings -> API -> Project API keys -> anon/public
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxbWdwcGduaGJvdGhtdnVkeHd6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyNDE3OTQsImV4cCI6MjA1NDgxNzc5NH0.UUjm8hDRYZRzsspaLTmsKBXj3NtAXeeMHEPFC5gccLM';
  
  // Table names
  static const String clientsTable = 'clients';
  
  // Column names (matching the database schema)
  static const String colId = 'id';
  static const String colFullName = 'full_name';
  static const String colUsername = 'username';
  static const String colPassword = 'password';
  static const String colContactNumber = 'contact_number';
  static const String colAddress = 'address';
  static const String colPlan = 'plan';
  static const String colInstallationDate = 'installation_date';
  static const String colExpirationDate = 'expiration_date';
  static const String colIsActive = 'is_active';
  static const String colLastSync = 'last_sync';
  static const String colSyncStatus = 'sync_status';
  static const String colLastModified = 'last_modified';
}
