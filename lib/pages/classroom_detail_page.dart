import 'package:flutter/material.dart';
import 'package:test123/services/classroom_service.dart';
import 'package:test123/services/module_service.dart';
import 'package:test123/services/quiz_service.dart';
import 'package:test123/models/classroom.dart';
import 'package:test123/models/module.dart';
import 'package:test123/models/quiz.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:test123/services/profile_service.dart';
import 'package:test123/models/profile.dart';

class ClassroomDetailPage extends StatefulWidget {
  final Classroom classroom;
  final String role;
  final String userId;

  const ClassroomDetailPage({
    super.key,
    required this.classroom,
    required this.role,
    required this.userId,
  });

  @override
  State<ClassroomDetailPage> createState() => _ClassroomDetailPageState();
}

class _ClassroomDetailPageState extends State<ClassroomDetailPage> {
  final ClassroomService _classroomService = ClassroomService();
  final ModuleService _moduleService = ModuleService();
  final QuizService _quizService = QuizService();
  final ProfileService _profileService = ProfileService();

  Classroom? classroom;
  Profile? lecturerProfile;
  List<Module> modules = [];
  List<Quiz> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final c = widget.classroom;

      final fetchedModules = await _moduleService.getModulesByClassroom(c.id);
      final fetchedQuizzes = await _quizService.getQuizzesByClassroom(c.id);

      final fetchedLecturerProfile = await _profileService.getProfile(
        c.lecturerId,
      );

      setState(() {
        classroom = c;
        modules = fetchedModules;
        quizzes = fetchedQuizzes;
        lecturerProfile = fetchedLecturerProfile;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildModuleCard(Module module) {
    return Card(
      child: ListTile(
        title: Text(module.title),
        subtitle: Text(module.fileType ?? 'No type'),
        trailing: Icon(Icons.file_present),
        onTap: () async {
          if (module.fileUrl != null &&
              await canLaunchUrl(Uri.parse(module.fileUrl!))) {
            launchUrl(Uri.parse(module.fileUrl!));
          }
        },
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Card(
      child: ListTile(
        title: Text(quiz.title),
        subtitle: Text(
          'Random Soal: ${quiz.isRandomizeQuestion}, Jawaban: ${quiz.isRandomizeAnswer}',
        ),
        trailing: Icon(Icons.quiz),
      ),
    );
  }

  void _showEditDeleteMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Kelas'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Hapus Kelas', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
              ),
            ],
          ),
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: classroom?.name ?? '');
    final descController = TextEditingController(
      text: classroom?.description ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Kelas'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama Kelas'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (classroom == null) return;
                  // Update kelas pakai classroomService
                  final updated = classroom!.copyWith(
                    name: nameController.text,
                    description: descController.text,
                  );
                  final newClassroom = await _classroomService.updateClassroom(
                    id: updated.id,
                    name: updated.name,
                    description: updated.description,
                  );
                  setState(() {
                    classroom = newClassroom;
                  });

                  Navigator.pop(context);
                },
                child: Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hapus Kelas'),
            content: Text('Apakah kamu yakin ingin menghapus kelas ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (classroom == null) return;
                  await _classroomService.deleteClassroom(classroom!.id);
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // Kembali dan beri tanda kelas dihapus
                },
                child: Text('Hapus'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(70),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    classroom?.name ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Kode Kelas: ${classroom?.code ?? ''}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (widget.role == 'lecturer')
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onPressed: _showEditDeleteMenu,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (classroom == null) {
      return const Scaffold(body: Center(child: Text('Kelas tidak ditemukan')));
    }

    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Text(
              'Dosen: ${lecturerProfile?.name ?? 'Tidak tersedia'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              classroom!.description ?? 'Tidak ada deskripsi kelas',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const Divider(height: 24),

            // Modul dan Quiz ditampilkan untuk semua role (lecturer & student)
            const Text(
              'Modul',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (modules.isEmpty)
              const Text('Belum ada modul.')
            else
              ...modules.map(_buildModuleCard).toList(),

            const SizedBox(height: 20),

            const Text(
              'Quiz',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (quizzes.isEmpty)
              const Text('Belum ada quiz.')
            else
              ...quizzes.map(_buildQuizCard).toList(),
          ],
        ),
      ),
    );
  }
}
