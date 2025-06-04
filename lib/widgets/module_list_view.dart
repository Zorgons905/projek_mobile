// lib/widgets/module_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test123/providers/library_providers.dart';
import 'package:test123/widgets/module_card_list.dart';

class ModuleListView extends ConsumerWidget {
  const ModuleListView({super.key, required this.id, required this.role});
  final String id;
  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredModules = ref.watch(filteredModulesProvider({'id': id, 'role': role}));
    // Pass the arguments to the family providers
    final classroomMap = ref.watch(classroomMapProvider({'id': id, 'role': role}));
    final lecturerMap = ref.watch(lecturerMapProvider({'id': id, 'role': role}));
    final progressMap = ref.watch(progressMapProvider({'id': id, 'role': role}));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredModules.length,
      itemBuilder: (context, index) {
        final module = filteredModules[index];
        final classroom = classroomMap[module.classroomId];
        final lecturer = classroom != null ? lecturerMap[classroom.lecturerId] : null;
        final progress = progressMap[module.id]?.progressPercent ?? 0.0;

        return ModuleCardList(
          module: module,
          lecturerName: lecturer?.name,
          progress: progress,
          isStudent: role == 'student',
        );
      },
    );
  }
}