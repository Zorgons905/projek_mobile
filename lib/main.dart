import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/pages/home_page.dart';
import 'package:test123/services/auth_gate.dart';
import 'package:test123/services/classroom_service.dart';
import 'package:test123/services/student_class_service.dart';
import 'package:uni_links/uni_links.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://gwwthlylotgwepuuyknh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3d3RobHlsb3Rnd2VwdXV5a25oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2OTUzNTgsImV4cCI6MjA2NDI3MTM1OH0.lzRAwas43s_dk7FTzTjIrEwzYfk5G5PxEeN7XIvWKFg',
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.path == '/join') {
        final code = uri.queryParameters['code'];
        if (code != null) {
          final classroom = await ClassroomService().getClassroomByCode(code);
          final studentId = Supabase.instance.client.auth.currentUser?.id;
          if (classroom != null && studentId != null) {
            final alreadyJoined = await StudentClassService().isStudentInClass(
              classroomId: classroom.id,
              studentId: studentId,
            );
            if (!alreadyJoined) {
              await StudentClassService().joinClass(
                classroomId: classroom.id,
                studentId: studentId,
              );
              // Tampilkan dialog/halaman sukses
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => HomePage(id: studentId, role: 'student'),
                ),
              );
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'READAILY',
      home: AuthGate(), // halaman login awal
    );
  }
}
