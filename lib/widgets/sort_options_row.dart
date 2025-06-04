// lib/widgets/sort_options_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test123/providers/library_providers.dart';

class SortOptionsRow extends ConsumerWidget {
  const SortOptionsRow({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(sortByProvider);
    final isAscending = ref.watch(isAscendingProvider);
    final isGridView = ref.watch(isGridViewProvider);

    Widget buildSortOption(String label, String value) {
      bool isActive = sortBy == value;
      IconData arrowIcon =
          isAscending ? Icons.arrow_upward : Icons.arrow_downward;

      return TextButton.icon(
        onPressed: () {
          ref.read(sortByProvider.notifier).state = value;
          ref.read(isAscendingProvider.notifier).state =
              (sortBy == value) ? !isAscending : true;
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

    return Container(
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
                  if (role == 'student') buildSortOption('Progress', 'progress'),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: isGridView ? 'List view' : 'Grid view',
            onPressed: () {
              ref.read(isGridViewProvider.notifier).state = !isGridView;
            },
          ),
        ],
      ),
    );
  }
}