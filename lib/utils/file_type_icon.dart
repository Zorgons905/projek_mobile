// lib/utils/file_type_icon.dart
import 'package:flutter/material.dart';

Widget getFileTypeIcon(String? type) {
  if (type == 'pdf') {
    return const Icon(Icons.picture_as_pdf, color: Colors.red);
  }
  if (type == 'doc' || type == 'docx') {
    return const Icon(Icons.description, color: Colors.blue);
  }
  return const Icon(Icons.insert_drive_file);
}