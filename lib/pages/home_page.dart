import 'package:flutter/material.dart';
import 'package:test123/services/student_class_service.dart';
import '../models/classroom.dart';
import '../services/classroom_service.dart';

class HomePage extends StatefulWidget {
  final String id;
  final String role;

  const HomePage({super.key, required this.id, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ClassroomService _classroomService = ClassroomService();
  final StudentClassService _studentClassService = StudentClassService();
  List<Classroom> _classrooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchClassrooms();
  }

  Future<void> _fetchClassrooms() async {
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

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _deleteClassroom(String id) async {
    await _classroomService.deleteClassroom(id);
    _showSnackbar('Kelas dihapus');
    _fetchClassrooms();
  }

  Future<void> _leaveClassroom(String classroomId) async {
    await _studentClassService.leaveClass(
      classroomId: classroomId,
      studentId: widget.id,
    );
    _showSnackbar('Berhasil keluar kelas');
    _fetchClassrooms();
  }

  void _editClassroom(Classroom classroom) {
    // Navigasi ke halaman edit
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
                          isLecturer: widget.role == 'lecturer',
                          onEdit: () => _editClassroom(classroom),
                          onDeleteOrLeave: () {
                            if (widget.role == 'lecturer') {
                              _deleteClassroom(classroom.id);
                            } else {
                              _leaveClassroom(classroom.id);
                            }
                          },
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
  final VoidCallback onEdit;
  final VoidCallback onDeleteOrLeave;
  final bool isLecturer;

  const _ClassroomCard({
    required this.data,
    required this.onEdit,
    required this.onDeleteOrLeave,
    required this.isLecturer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      width: double.infinity,
      height: 140,
      child: Stack(
        children: [
          // Background dekorasi bulatan besar di pojok
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade300.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Background dekorasi kotak kecil transparan di kiri bawah
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade200.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Card utama
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
                // Informasi kelas
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

                // Menu titik tiga
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete_leave') {
                      onDeleteOrLeave();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if (isLecturer) {
                      return [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete_leave',
                          child: Text('Hapus'),
                        ),
                      ];
                    } else {
                      return [
                        const PopupMenuItem(
                          value: 'delete_leave',
                          child: Text('Keluar Kelas'),
                        ),
                      ];
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




  // final ClassroomService _classroomService = ClassroomService();

  // late Future<List<Map<String, dynamic>>> _futureClassrooms;

  // @override
  // void initState() {
  //   super.initState();
  //   _futureClassrooms = _fetchClassrooms();
  // }

  // Future<List<Map<String, dynamic>>> _fetchClassrooms() {
  //   if (widget.role == 'lecturer') {
  //     return _classroomService.getClassroomsByLecturer(widget.id);
  //   } else {
  //     return _classroomService.getClassroomsByStudent(widget.id);
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   final isLecturer = widget.role == 'lecturer';

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Daftar Kelas'),
  //       backgroundColor: Colors.blue[700],
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: FutureBuilder<List<Map<String, dynamic>>>(
  //         future: _futureClassrooms,
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.waiting) {
  //             return const Center(child: CircularProgressIndicator());
  //           }

  //           if (snapshot.hasError) {
  //             return Center(
  //               child: Text('Terjadi kesalahan: ${snapshot.error}'),
  //             );
  //           }

  //           final classrooms = snapshot.data ?? [];

  //           if (classrooms.isEmpty) {
  //             return const Center(child: Text('Belum ada kelas.'));
  //           }

  //           return ListView.builder(
  //             itemCount: classrooms.length,
  //             itemBuilder: (context, index) {
  //               final classroom =
  //                   isLecturer
  //                       ? classrooms[index] // langsung
  //                       : classrooms[index]['classroom']; // dari relasi student_class

  //               return GestureDetector(
  //                 onTap: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder:
  //                           (_) => ClassroomDetailPage(
  //                             classroomId: classroom['id'].toString(),
  //                             classroomName: classroom['name'],
  //                             role: widget.role,
  //                           ),
  //                     ),
  //                   );
  //                 },
  //                 child: Container(
  //                   margin: const EdgeInsets.only(bottom: 16),
  //                   padding: const EdgeInsets.all(16),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(12),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         blurRadius: 4,
  //                         color: Colors.black12,
  //                         offset: const Offset(2, 2),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         classroom['name'],
  //                         style: const TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 6),
  //                       Text(
  //                         isLecturer
  //                             ? 'Kode Kelas: ${classroom['code']}'
  //                             : 'Dosen: ${classroom['lecturer_id']}',
  //                         style: TextStyle(color: Colors.grey[700]),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
