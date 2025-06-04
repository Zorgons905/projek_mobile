import 'package:flutter/material.dart';
import 'package:test123/services/classroom_service.dart';

class CreateClassPage extends StatefulWidget {
  final String lecturerId;

  const CreateClassPage({super.key, required this.lecturerId});

  @override
  State<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final ClassroomService _classroomService = ClassroomService();

  bool _isCreating = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final classroom = await _classroomService.createClassroom(
        name: _nameController.text,
        description: _descController.text,
        lecturerId: widget.lecturerId,
      );

      Navigator.pop(context, classroom); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat kelas: $e')));
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Kelas Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kelas'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi Kelas'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isCreating ? null : _submit,
                child:
                    _isCreating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Buat Kelas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
