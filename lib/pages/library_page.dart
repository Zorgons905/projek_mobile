// lib/pages/library_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test123/providers/library_providers.dart';
import 'package:test123/widgets/library_app_bar.dart';
import 'package:test123/widgets/module_grid_view.dart';
import 'package:test123/widgets/module_list_view.dart';
import 'package:test123/widgets/sort_options_row.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key, required this.id, required this.role});
  final String id;
  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('LibraryPage build: ID=$id, Role=$role'); // Add this line

    final isGridView = ref.watch(isGridViewProvider);
    final modulesAsyncValue = ref.watch(
      modulesProvider({'id': id, 'role': role}),
    );

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Column(
          children: [
            LibraryAppBar(role: role),
            SortOptionsRow(role: role),
            Expanded(
              child: modulesAsyncValue.when(
                data: (modulesData) {
                  // Changed 'modules' to 'modulesData' as modulesProvider now returns ModulesData
                  if (modulesData.modules.isEmpty) {
                    // Access modules from modulesData
                    return const Center(child: Text('No modules found.'));
                  }
                  return isGridView
                      ? ModuleGridView(id: id, role: role)
                      : ModuleListView(id: id, role: role);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
