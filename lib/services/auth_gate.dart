import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Import the provider package
import '../components/navbar.dart';
import '../pages/login_page.dart';
import '../providers/classroom_provider.dart'; // Import your ClassroomProvider

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        // If no session, show the login page
        if (session == null) {
          return const LoginPage();
        }

        // If there's a session, fetch the user's role and then fetch classrooms
        return FutureBuilder(
          future: Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('id', session.user.id)
              .maybeSingle(),
          builder: (context, roleSnapshot) {
            // Show a loading indicator while fetching the role
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userRole = roleSnapshot.data?['role'] ?? 'student'; // Default to 'student' or 'unknown'

            // Now, fetch classrooms using the ClassroomProvider
            // We use a nested FutureBuilder or just call the fetch method
            // directly here before returning Navbar.
            // Using a Consumer or directly calling Provider.of in build is fine
            // if you ensure the fetch is only triggered once or on specific conditions.
            return FutureBuilder(
              future: Provider.of<ClassroomProvider>(context, listen: false)
                  .fetchClassrooms(session.user.id, userRole),
              builder: (context, classroomFetchSnapshot) {
                // Show a loading indicator while fetching classrooms
                if (classroomFetchSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Handle any errors during classroom fetching
                if (classroomFetchSnapshot.hasError) {
                  print('Error fetching classrooms in AuthGate: ${classroomFetchSnapshot.error}');
                  // You might want to show an error message or retry option
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Failed to load classes.'),
                          Text('Error: ${classroomFetchSnapshot.error}'),
                          ElevatedButton(
                            onPressed: () {
                              // Re-trigger the fetch if needed, perhaps by navigating to a new AuthGate instance
                              // For simplicity, we just rebuild here.
                              // In a real app, you might use a stateful widget and setState to retry.
                              // Or more robustly, navigate to an error page with a retry button.
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const AuthGate()),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // If role and classrooms are fetched, show the Navbar
                // Navbar will then navigate to HomePage, which will find the data ready
                return Navbar(role: userRole);
              },
            );
          },
        );
      },
    );
  }
}