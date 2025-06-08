import 'package:flutter/material.dart';
import '../services/student_class_service.dart';
import '../services/classroom_service.dart';

class JoinClassPage extends StatefulWidget {
  final String studentId;

  const JoinClassPage({super.key, required this.studentId});

  @override
  State<JoinClassPage> createState() => _JoinClassPageState();
}

class _JoinClassPageState extends State<JoinClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  final ClassroomService _classroomService = ClassroomService();
  final StudentClassService _studentClassService = StudentClassService();

  bool _isJoining = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isJoining = true);

    try {
      final code = _codeController.text.trim().toUpperCase();
      final classroom = await _classroomService.getClassroomByCode(code);

      if (classroom == null) {
        throw Exception("Kode kelas tidak ditemukan.");
      }

      final alreadyJoined = await _studentClassService.isStudentInClass(
        classroomId: classroom.id,
        studentId: widget.studentId,
      );

      if (alreadyJoined) {
        throw Exception("Kamu sudah bergabung dengan kelas ini.");
      }

      await _studentClassService.joinClass(
        classroomId: classroom.id,
        studentId: widget.studentId,
      );

      Navigator.pop(
        context,
        classroom,
      ); // Kembali dan kirim data kelas yang baru di-join
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal bergabung: ${e.toString()}')),
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gabung Kelas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Kode Kelas'),
                textCapitalization: TextCapitalization.characters,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Kode tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isJoining ? null : _submit,
                child:
                    _isJoining
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Gabung'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
