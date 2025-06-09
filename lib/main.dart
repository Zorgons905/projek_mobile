import 'package:flutter/material.dart';
import 'package:readaily/providers/classroom_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Import the provider package

import '../services/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gwwthlylotgwepuuyknh.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3d3RobHlsb3Rnd2VwdXV5a25oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2OTUzNTgsImV4cCI6MjA2NDI3MTM1OH0.lzRAwas43s_dk7FTzTjIrEwzYfk5G5PxEeN7XIvWKFg',
    debug: true,
  );

  runApp(
    // Wrap your app with MultiProvider to provide ClassroomProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClassroomProvider()),
        // Add other providers here if you have more services to manage
      ],
      child: const MyApp(), // Your main app widget
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // No need to fetch data here; HomePage will trigger the fetch
  }

  @override
  void dispose() {
    // You typically don't need to dispose providers manually here
    // as MultiProvider handles their lifecycle.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Readaily',
      home: AuthGate(), // AuthGate will eventually lead to HomePage
    );
  }
}