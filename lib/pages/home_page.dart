import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import provider
import '../pages/classroom_detail_page.dart';
import '../models/classroom.dart';
import '../providers/classroom_provider.dart';

class HomePage extends StatefulWidget {
  final String id;
  final String role;

  const HomePage({super.key, required this.id, required this.role});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ClassroomProvider for changes
    final classroomProvider = Provider.of<ClassroomProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Column(
        children: [
          const _CustomAppBar(),
          Expanded(
            child: classroomProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : classroomProvider.errorMessage != null
                ? Center(child: Text('Error: ${classroomProvider.errorMessage}'))
                : classroomProvider.classrooms.isEmpty
                ? const Center(child: Text('Belum ada kelas'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: classroomProvider.classrooms.length,
              itemBuilder: (context, index) {
                final classroom = classroomProvider.classrooms[index];
                return _ClassroomCard(
                  data: classroom,
                  id: widget.id,
                  role: widget.role,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// _CustomAppBar and _ClassroomCard remain mostly the same as they don't directly
// interact with the provider for data fetching, only using the data passed to them.
// If _ClassroomCard needs to trigger an action (e.g., delete classroom) that
// modifies the list, it would also use Provider.of<ClassroomProvider>(context, listen: false).method().

class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'READAILY',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              letterSpacing: 1.2,
            ),
          ),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
    );
  }
}

class _ClassroomCard extends StatelessWidget {
  final Classroom data;
  final String id;
  final String role;

  const _ClassroomCard({
    required this.data,
    required this.role,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassroomDetailPage(
              classroom: data,
              role: role,
              userId: id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        width: double.infinity,
        height: 140,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info kelas
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.description ?? '-',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.blue.shade100,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Kode: ${data.code}',
                            style: TextStyle(
                              color: Colors.blue.shade100,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tombol rantai
                    GestureDetector(
                      onTap: () {
                        final joinLink = 'readaily://join?code=${data.code}';
                        Clipboard.setData(ClipboardData(text: joinLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link kelas disalin')),
                        );
                      },
                      behavior: HitTestBehavior.translucent,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.link, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Dekorasi tambahan...
              Positioned(
                top: -10,
                left: -20,
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                top: 80,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(500),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}