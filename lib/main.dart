import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/home_page.dart';
import '../services/auth_gate.dart';
import '../services/classroom_service.dart';
import '../services/student_class_service.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  StreamSubscription<Uri>? _linkSubscription;
  final navigatorKey = GlobalKey<NavigatorState>();
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) async {
      if (uri.path == '/join') {
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
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Readaily',
      home: AuthGate(),
    );
  }
}
