import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl {
    return dotenv.get('SUPABASE_URL', fallback: "");
  }

  static String get supabaseAnonKey {
    return dotenv.get('SUPABASE_ANON_KEY', fallback: "");
  }

  static String get backendApiUrl {
    return dotenv.get('BACKEND_API_URL', fallback: "");
  }
}
