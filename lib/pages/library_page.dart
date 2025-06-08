import 'package:flutter/material.dart';
import '../models/module.dart';
import '../models/classroom.dart';
import '../models/profile.dart';
import '../models/student_module_progress.dart';
import '../services/classroom_service.dart';
import '../services/module_service.dart';
import '../services/profile_service.dart';
import '../services/student_class_service.dart';
import '../services/student_module_progress_service.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, required this.id, required this.role});
  final String id;
  final String role;

  @override
  State<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  final ModuleService _moduleService = ModuleService();
  final ClassroomService _classroomService = ClassroomService();
  final ProfileService _profileService = ProfileService();
  final StudentClassService _studentClassService = StudentClassService();
  final StudentModuleProgressService _progressService =
      StudentModuleProgressService();

  List<Module> modules = [];
  Map<String, Classroom> classroomMap = {};
  Map<String, Profile> lecturerMap = {};
  Map<String, StudentModuleProgress> progressMap = {};

  bool isLoading = true;

  // Sorting & Searching
  String sortBy = 'name';
  bool isAscending = true;
  String searchQuery = '';
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  Future<void> fetchModules() async {
    List<Module> fetchedModules = [];

    if (widget.role == 'lecturer') {
      final classes = await _classroomService.getClassroomsByLecturer(
        widget.id,
      );
      for (var c in classes) {
        final mods = await _moduleService.getModulesByClassroom(c.id);
        fetchedModules.addAll(mods);
        classroomMap[c.id] = c;
      }
    } else {
      final studentClasses = await _studentClassService.getStudentClasses(
        widget.id,
      );
      for (var sc in studentClasses) {
        final classroom = await _classroomService.getClassroom(sc.classroomId);
        if (classroom != null) {
          final mods = await _moduleService.getModulesByClassroom(classroom.id);
          fetchedModules.addAll(mods);
          classroomMap[classroom.id] = classroom;
        }
      }

      // Get student progress
      final allProgress = await _progressService.getStudentProgress(widget.id);
      for (var prog in allProgress) {
        progressMap[prog.moduleId] = prog;
      }
    }

    // Lecturer profiles
    for (var c in classroomMap.values) {
      if (!lecturerMap.containsKey(c.lecturerId)) {
        final prof = await _profileService.getProfile(c.lecturerId);
        if (prof != null) lecturerMap[c.lecturerId] = prof;
      }
    }

    setState(() {
      modules = fetchedModules;
      isLoading = false;
    });
  }

  List<Module> get filteredModules {
    var filtered =
        modules
            .where(
              (m) => m.title.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    if (sortBy == 'name') {
      filtered.sort(
        (a, b) =>
            isAscending
                ? a.title.compareTo(b.title)
                : b.title.compareTo(a.title),
      );
    } else if (sortBy == 'date') {
      filtered.sort(
        (a, b) =>
            isAscending
                ? a.uploadedAt!.compareTo(b.uploadedAt!)
                : b.uploadedAt!.compareTo(a.uploadedAt!),
      );
    } else if (sortBy == 'progress' && widget.role == 'student') {
      filtered.sort((a, b) {
        final aProgress = progressMap[a.id]?.progressPercent ?? 0;
        final bProgress = progressMap[b.id]?.progressPercent ?? 0;
        return isAscending
            ? aProgress.compareTo(bProgress)
            : bProgress.compareTo(aProgress);
      });
    }

    return filtered;
  }

  Widget getFileTypeIcon(String? type) {
    if (type == 'pdf') {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    }
    if (type == 'doc' || type == 'docx') {
      return const Icon(Icons.description, color: Colors.blue);
    }
    return const Icon(Icons.insert_drive_file);
  }

  Widget buildSortOption(String label, String value) {
    bool isActive = sortBy == value;
    IconData arrowIcon =
        isAscending ? Icons.arrow_upward : Icons.arrow_downward;

    return TextButton.icon(
      onPressed: () {
        setState(() {
          if (sortBy == value) {
            isAscending = !isAscending;
          } else {
            sortBy = value;
            isAscending = true;
          }
        });
      },
      icon: isActive ? Icon(arrowIcon, size: 16) : const SizedBox(),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar with search
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search modules...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Sort options
            // Sort options + toggle layout
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildSortOption('Name', 'name'),
                          buildSortOption('Date', 'date'),
                          if (widget.role == 'student')
                            buildSortOption('Progress', 'progress'),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
                    tooltip: isGridView ? 'List view' : 'Grid view',
                    onPressed: () {
                      setState(() {
                        isGridView = !isGridView;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isGridView
                      ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                        itemCount: filteredModules.length,
                        itemBuilder: (context, index) {
                          final module = filteredModules[index];
                          final classroom = classroomMap[module.classroomId];
                          final lecturer =
                              classroom != null
                                  ? lecturerMap[classroom.lecturerId]
                                  : null;
                          final progress =
                              progressMap[module.id]?.progressPercent ?? 0.0;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getFileTypeIcon(module.fileType),
                                  const SizedBox(height: 8),
                                  Text(
                                    module.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    lecturer?.name ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (widget.role == 'student') ...[
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredModules.length,
                        itemBuilder: (context, index) {
                          final module = filteredModules[index];
                          final classroom = classroomMap[module.classroomId];
                          final lecturer =
                              classroom != null
                                  ? lecturerMap[classroom.lecturerId]
                                  : null;
                          final progress =
                              progressMap[module.id]?.progressPercent ?? 0.0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      getFileTypeIcon(module.fileType),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          module.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'By: ${lecturer?.name ?? 'Unknown'}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (widget.role == 'student') ...[
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${progress.toStringAsFixed(1)}% completed',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
