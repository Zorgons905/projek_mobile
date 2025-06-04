import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/services/auth_gate.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://gwwthlylotgwepuuyknh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3d3RobHlsb3Rnd2VwdXV5a25oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2OTUzNTgsImV4cCI6MjA2NDI3MTM1OH0.lzRAwas43s_dk7FTzTjIrEwzYfk5G5PxEeN7XIvWKFg',
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AuthGate());
  }
}