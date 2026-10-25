import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static  String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://lskwrhujwhbxdefasppr.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxza3dyaHVqd2hieGRlZmFzcHByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1ODA3MzIsImV4cCI6MjA4MTE1NjczMn0.1O_7OARrC4lSaFzyigEPes5Pn1j9s1aZE2l4ZwnSJCE';
}
