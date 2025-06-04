// lib/widgets/module_card_list.dart
import 'package:flutter/material.dart';
import 'package:test123/models/module.dart';
import 'package:test123/utils/file_type_icon.dart'; // Create this utility

class ModuleCardList extends StatelessWidget {
  const ModuleCardList({
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
              'By: ${lecturerName ?? 'Unknown'}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (isStudent) ...[
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
  }
}