import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../providers/classroom_provider.dart'; // Import your ClassroomProvider

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
  // Removed: final ClassroomService _classroomService = ClassroomService(); // No longer instantiate directly

  bool _isCreating = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      // Access the ClassroomProvider and call its createClassroom method
      final classroomProvider = Provider.of<ClassroomProvider>(context, listen: false);
      final classroom = await classroomProvider.createClassroom(
        name: _nameController.text,
        description: _descController.text,
        lecturerId: widget.lecturerId,
      );

      if (classroom != null) {
        // Class successfully created and provider notified its listeners
        if (mounted) { // Check if the widget is still mounted before popping
          Navigator.pop(context); // Just pop, no need to pass data back explicitly
        }
      } else {
        // Handle error if classroom was not created (e.g., error message from provider)
        if (mounted && classroomProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat kelas: ${classroomProvider.errorMessage}')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuat kelas: Terjadi kesalahan tidak dikenal')),
          );
        }
      }
    } catch (e) {
      // This catch block would only be hit if something unexpected happens
      // outside of the provider's try-catch.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan eksternal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
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
                validator: (value) =>
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
                child: _isCreating
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