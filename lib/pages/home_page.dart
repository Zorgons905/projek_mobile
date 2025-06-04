import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test123/pages/classroom_detail_page.dart';
import 'package:test123/services/student_class_service.dart';
import '../models/classroom.dart';
import '../services/classroom_service.dart';

class HomePage extends StatefulWidget {
  final String id;
  final String role;

  const HomePage({super.key, required this.id, required this.role});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ClassroomService _classroomService = ClassroomService();
  final StudentClassService _studentClassService = StudentClassService();
  List<Classroom> _classrooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchClassrooms();
  }

  Future<void> fetchClassrooms() async {
    setState(() => _loading = true);
    if (widget.role == 'lecturer') {
      _classrooms = await _classroomService.getClassroomsByLecturer(widget.id);
    } else {
      // Untuk student, ambil dulu student_class dulu
      final studentClasses = await _studentClassService.getStudentClasses(
        widget.id,
      );

      // Dari relasi student_class ambil classroom_id dan fetch class data
      final classrooms = <Classroom>[];
      for (final sc in studentClasses) {
        final classroom = await _classroomService.getClassroom(sc.classroomId);
        if (classroom != null) {
          classrooms.add(classroom);
        }
      }
      _classrooms = classrooms;
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Column(
        children: [
          const _CustomAppBar(),
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _classrooms.isEmpty
                    ? const Center(child: Text('Belum ada kelas'))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _classrooms.length,
                      itemBuilder: (context, index) {
                        final classroom = _classrooms[index];
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
            builder:
                (_) => ClassroomDetailPage(
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