import 'package:flutter/material.dart';
import '../services/classroom_service.dart';

class StudentsInClassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
  // final String classroomId;
  // final ClassroomService _service = ClassroomService();

  // StudentsInClassPage({super.key, required this.classroomId});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Daftar Mahasiswa')),
  //     body: FutureBuilder<List<Map<String, dynamic>>>(
  //       future: _service.getStudentsInClass(classroomId),
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         if (snapshot.hasError) {
  //           return Center(child: Text('Error: ${snapshot.error}'));
  //         }

  //         final students = snapshot.data!;
  //         if (students.isEmpty) {
  //           return const Center(child: Text('Belum ada mahasiswa.'));
  //         }

  //         return ListView.builder(
  //           itemCount: students.length,
  //           itemBuilder: (context, index) {
  //             final student = students[index]['profiles'];
  //             return ListTile(
  //               leading: const Icon(Icons.person),
  //               title: Text(student['name']),
  //               subtitle: Text(student['email']),
  //             );
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }
}
