import 'package:flutter/material.dart';
import 'package:test123/pages/student_in_class_page.dart';
import '../services/classroom_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassroomDetailPage extends StatefulWidget {
  final String classroomId;
  final String classroomName;
  final String role;

  const ClassroomDetailPage({
    super.key,
    required this.classroomId,
    required this.classroomName,
    required this.role,
  });

  @override
  State<ClassroomDetailPage> createState() => _ClassroomDetailPageState();
}

class _ClassroomDetailPageState extends State<ClassroomDetailPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
  // final ClassroomService _classroomService = ClassroomService();
  // late Future<Map<String, dynamic>> _futureDetail;

  // @override
  // void initState() {
  //   super.initState();
  //   _futureDetail = _classroomService.getClassroomDetail(widget.classroomId);
  // }

  // @override
  // Widget build(BuildContext context) {
  //   final isLecturer = widget.role == 'lecturer';

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.classroomName),
  //       backgroundColor: Colors.blue[700],
  //     ),
  //     body: FutureBuilder<Map<String, dynamic>>(
  //       future: _futureDetail,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         if (snapshot.hasError) {
  //           return Center(child: Text('Error: ${snapshot.error}'));
  //         }

  //         final classroom = snapshot.data!;
  //         final modules = classroom['modules'] as List<dynamic>;

  //         final books = modules.where((m) => m['type'] == 'book').toList();
  //         final quizzes = modules.where((m) => m['type'] == 'quiz').toList();

  //         return SingleChildScrollView(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               _buildInfoTile('Nama Kelas', classroom['name']),
  //               _buildInfoTile('Kode Kelas', classroom['code']),
  //               _buildInfoTile('ID Dosen', classroom['lecturer_id']),
  //               const SizedBox(height: 24),
  //               if (isLecturer)
  //                 ElevatedButton.icon(
  //                   onPressed: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder:
  //                             (context) => StudentsInClassPage(
  //                               classroomId: widget.classroomId,
  //                             ),
  //                       ),
  //                     );
  //                   },
  //                   icon: const Icon(Icons.people),
  //                   label: const Text('Lihat Mahasiswa'),
  //                 )
  //               else
  //                 Text(
  //                   'Kamu adalah mahasiswa di kelas ini.',
  //                   style: TextStyle(color: Colors.grey[700]),
  //                 ),
  //               const SizedBox(height: 32),
  //               Text(
  //                 '📚 Daftar Buku',
  //                 style: Theme.of(context).textTheme.titleMedium,
  //               ),
  //               ...books.map((book) => _buildModuleCard(book, isLecturer)),
  //               const SizedBox(height: 24),
  //               Text(
  //                 '❓ Daftar Kuis',
  //                 style: Theme.of(context).textTheme.titleMedium,
  //               ),
  //               ...quizzes.map((quiz) => _buildModuleCard(quiz, isLecturer)),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _buildInfoTile(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(label, style: Theme.of(context).textTheme.titleSmall),
  //         Text(value, style: Theme.of(context).textTheme.bodyLarge),
  //         const SizedBox(height: 8),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildModuleCard(Map module, bool isLecturer) {
  //   final title = module['title'] ?? 'Tanpa Judul';
  //   final desc = module['description'] ?? '';
  //   final fileUrl = module['file_url'];

  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     child: ListTile(
  //       leading: Icon(
  //         module['type'] == 'book' ? Icons.book : Icons.quiz,
  //         color: Colors.blue[700],
  //       ),
  //       title: Text(title),
  //       subtitle: Text(desc),
  //       trailing:
  //           isLecturer
  //               ? IconButton(
  //                 icon: const Icon(Icons.edit),
  //                 onPressed: () {
  //                   // TODO: Navigasi ke halaman edit modul
  //                 },
  //               )
  //               : const Icon(Icons.chevron_right),
  //       onTap:
  //           fileUrl != null
  //               ? () async {
  //                 final uri = Uri.parse(fileUrl);
  //                 if (await canLaunchUrl(uri)) {
  //                   await launchUrl(uri, mode: LaunchMode.externalApplication);
  //                 } else {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('Tidak dapat membuka file')),
  //                   );
  //                 }
  //               }
  //               : null,
  //     ),
  //   );
  // }
}
