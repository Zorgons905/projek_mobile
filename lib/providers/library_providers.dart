// lib/providers/library_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test123/models/classroom.dart';
import 'package:test123/models/module.dart';
import 'package:test123/models/profile.dart';
import 'package:test123/models/student_module_progress.dart';
import 'package:test123/services/classroom_service.dart';
import 'package:test123/services/module_service.dart';
import 'package:test123/services/profile_service.dart';
import 'package:test123/services/student_class_service.dart';
import 'package:test123/services/student_module_progress_service.dart';

// Service Providers (remain unchanged)
final moduleServiceProvider = Provider((ref) => ModuleService());
final classroomServiceProvider = Provider((ref) => ClassroomService());
final profileServiceProvider = Provider((ref) => ProfileService());
final studentClassServiceProvider = Provider((ref) => StudentClassService());
final studentModuleProgressServiceProvider =
    Provider((ref) => StudentModuleProgressService());

// State Notifiers for UI State (remain unchanged)
final searchQueryProvider = StateProvider<String>((ref) => '');
final sortByProvider = StateProvider<String>((ref) => 'name');
final isAscendingProvider = StateProvider<bool>((ref) => true);
final isGridViewProvider = StateProvider<bool>((ref) => false);

// AsyncNotifier for fetching and managing modules
// It will now RETURN a custom data structure that includes modules AND the maps
class ModulesData {
  final List<Module> modules;
  final Map<String, Classroom> classroomMap;
  final Map<String, Profile> lecturerMap;
  final Map<String, StudentModuleProgress> progressMap;

  ModulesData({
    required this.modules,
    required this.classroomMap,
    required this.lecturerMap,
    required this.progressMap,
  });
}

class ModulesNotifier extends FamilyAsyncNotifier<ModulesData, Map<String, String>> {
  @override
  Future<ModulesData> build(Map<String, String> arg) async {
    print('ModulesNotifier build started for ID: ${arg['id']}, Role: ${arg['role']}');
    final String userId = arg['id']!;
    final String role = arg['role']!;

    final moduleService = ref.watch(moduleServiceProvider);
    final classroomService = ref.watch(classroomServiceProvider);
    final profileService = ref.watch(profileServiceProvider);
    final studentClassService = ref.watch(studentClassServiceProvider);
    final progressService = ref.watch(studentModuleProgressServiceProvider);

    List<Module> fetchedModules = [];
    Map<String, Classroom> tempClassroomMap = {};
    Map<String, Profile> tempLecturerMap = {};
    Map<String, StudentModuleProgress> tempProgressMap = {};

    try {
      if (role == 'lecturer') {
        print('Fetching classrooms by lecturer: $userId');
        final classes = await classroomService.getClassroomsByLecturer(userId);
        print('Fetched ${classes.length} classrooms.');
        for (var c in classes) {
          print('Fetching modules for classroom: ${c.id}');
          final mods = await moduleService.getModulesByClassroom(c.id);
          fetchedModules.addAll(mods);
          tempClassroomMap[c.id] = c;
        }
      } else {
        print('Fetching student classes for student: $userId');
        final studentClasses = await studentClassService.getStudentClasses(userId);
        print('Fetched ${studentClasses.length} student classes.');
        for (var sc in studentClasses) {
          print('Fetching classroom: ${sc.classroomId}');
          final classroom = await classroomService.getClassroom(sc.classroomId);
          if (classroom != null) {
            print('Fetching modules for classroom: ${classroom.id}');
            final mods = await moduleService.getModulesByClassroom(classroom.id);
            fetchedModules.addAll(mods);
            tempClassroomMap[classroom.id] = classroom;
          }
        }
        print('Fetching student progress for student: $userId');
        final allProgress = await progressService.getStudentProgress(userId);
        for (var prog in allProgress) {
          tempProgressMap[prog.moduleId] = prog;
        }
        print('Fetched ${allProgress.length} progress entries.');
      }

      print('Fetching lecturer profiles...');
      for (var c in tempClassroomMap.values) {
        if (!tempLecturerMap.containsKey(c.lecturerId)) {
          final prof = await profileService.getProfile(c.lecturerId);
          if (prof != null) tempLecturerMap[c.lecturerId] = prof;
        }
      }
      print('Finished fetching lecturer profiles.');

      // Instead of updating separate StateProviders, return a combined object
      print('ModulesNotifier build completed with ${fetchedModules.length} modules.');
      return ModulesData(
        modules: fetchedModules,
        classroomMap: tempClassroomMap,
        lecturerMap: tempLecturerMap,
        progressMap: tempProgressMap,
      );
    } catch (e, st) {
      print('ModulesNotifier caught error: $e\n$st');
      rethrow; // Re-throw the error so Riverpod can catch it and display it in `error` state
    }
  }
}

// modulesProvider now returns ModulesData
final modulesProvider = AsyncNotifierProvider.family<ModulesNotifier, ModulesData, Map<String, String>>(
  ModulesNotifier.new,
);

// Derived Providers for maps - these are now calculated from modulesProvider's data
// These no longer need to be StateProviders
final classroomMapProvider = Provider.family<Map<String, Classroom>, Map<String, String>>((ref, args) {
  return ref.watch(modulesProvider(args)).when(
    data: (data) => data.classroomMap,
    loading: () => {}, // Return empty map while loading
    error: (err, stack) => {}, // Return empty map on error
  );
});

final lecturerMapProvider = Provider.family<Map<String, Profile>, Map<String, String>>((ref, args) {
  return ref.watch(modulesProvider(args)).when(
    data: (data) => data.lecturerMap,
    loading: () => {},
    error: (err, stack) => {},
  );
});

final progressMapProvider = Provider.family<Map<String, StudentModuleProgress>, Map<String, String>>((ref, args) {
  return ref.watch(modulesProvider(args)).when(
    data: (data) => data.progressMap,
    loading: () => {},
    error: (err, stack) => {},
  );
});


// Selector Provider for filtered and sorted modules
// This provider still takes the userId and role as arguments
final filteredModulesProvider = Provider.family<List<Module>, Map<String, String>>((ref, args) {
  final String userId = args['id']!; // Keep this if needed for some specific filtering logic
  final String role = args['role']!;

  // We now watch the modulesProvider, which provides the full ModulesData object
  final modulesDataAsyncValue = ref.watch(modulesProvider({'id': userId, 'role': role}));
  final searchQuery = ref.watch(searchQueryProvider);
  final sortBy = ref.watch(sortByProvider);
  final isAscending = ref.watch(isAscendingProvider);

  // Retrieve progressMap directly from the modulesDataAsyncValue
  final progressMap = modulesDataAsyncValue.when(
    data: (data) => data.progressMap,
    loading: () => {}, // Return empty map during loading/error
    error: (err, stack) => {},
  );


  return modulesDataAsyncValue.when(
    data: (modulesData) {
      var filtered = modulesData.modules // Use modules from the ModulesData object
          .where(
            (m) => m.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();

      if (sortBy == 'name') {
        filtered.sort(
          (a, b) =>
              isAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title),
        );
      } else if (sortBy == 'date') {
        filtered.sort(
          (a, b) =>
              isAscending ? a.uploadedAt!.compareTo(b.uploadedAt!) : b.uploadedAt!.compareTo(a.uploadedAt!),
        );
      } else if (sortBy == 'progress' && role == 'student') {
        filtered.sort((a, b) {
          final aProgress = progressMap[a.id]?.progressPercent ?? 0;
          final bProgress = progressMap[b.id]?.progressPercent ?? 0;
          return isAscending
              ? aProgress.compareTo(bProgress)
              : bProgress.compareTo(aProgress);
        });
      }
      return filtered;
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});