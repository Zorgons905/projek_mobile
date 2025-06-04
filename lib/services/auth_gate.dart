// AuthGate.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/components/navbar.dart';
import 'package:test123/pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) {
          return const LoginPage();
        }

        return FutureBuilder(
          future:
              Supabase.instance.client
                  .from('profiles')
                  .select('role')
                  .eq('id', session.user.id)
                  .maybeSingle(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data?['role'] ?? 'unknown';

            return Navbar(role: role);
          },
        );
      },
    );
  }
}
