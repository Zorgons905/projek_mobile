// lib/widgets/module_card_grid.dart
import 'package:flutter/material.dart';
import 'package:test123/models/module.dart';
import 'package:test123/utils/file_type_icon.dart'; // Create this utility

class ModuleCardGrid extends StatelessWidget {
  const ModuleCardGrid({
    super.key,
    required this.module,
    this.lecturerName,
    required this.progress,
    required this.isStudent,
  });

  final Module module;
  final String? lecturerName;
  final double progress;
  final bool isStudent;

  @override
  Widget build(BuildContext context) {
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
              lecturerName ?? 'Unknown',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (isStudent) ...[
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
  }
}