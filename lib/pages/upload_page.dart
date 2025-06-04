import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/models/classroom.dart';
import 'package:test123/services/classroom_service.dart';

class UploadPage extends StatefulWidget {
  final String lecturerId; // penting!

  const UploadPage({super.key, required this.lecturerId});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final classroomService = ClassroomService();
  final titleController = TextEditingController();

  String? selectedClassroomId;
  List<Classroom> classrooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    try {
      final result = await classroomService.getClassroomsByLecturer(
        widget.lecturerId,
      );
      setState(() {
        classrooms = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal ambil classroom: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> uploadModule({
    required BuildContext context,
    required String classroomId,
    required String title,
  }) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.single.bytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tidak ada file dipilih")));
      return;
    }

    final fileBytes = result.files.single.bytes!;
    final originalName = result.files.single.name;
    final fileExt = result.files.single.extension ?? 'unknown';

    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = '$userId/${timestamp}_$originalName';

    final storage = Supabase.instance.client.storage;

    try {
      await storage.from('modules').uploadBinary(uniqueFileName, fileBytes);
      final fileUrl = storage.from('modules').getPublicUrl(uniqueFileName);

      await Supabase.instance.client.from('module').insert({
        'classroom_id': classroomId,
        'title': title,
        'file_url': fileUrl,
        'file_type': fileExt,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ File berhasil diunggah")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Gagal upload: $e")));
        debugPrint("Upload error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Module")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pilih Kelas",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: selectedClassroomId,
                      hint: const Text("Pilih Classroom"),
                      isExpanded: true,
                      items:
                          classrooms.map((classroom) {
                            return DropdownMenuItem<String>(
                              value: classroom.id.toString(),
                              child: Text(classroom.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClassroomId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Judul File",
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedClassroomId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Pilih kelas terlebih dahulu"),
                            ),
                          );
                          return;
                        }
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Masukkan judul file dulu"),
                            ),
                          );
                          return;
                        }

                        uploadModule(
                          context: context,
                          classroomId: selectedClassroomId!,
                          title: titleController.text,
                        );
                      },
                      child: const Text("Pilih & Upload File"),
                    ),
                  ],
                ),
      ),
    );
  }
}
