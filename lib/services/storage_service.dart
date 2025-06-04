import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadBytes({
    required Uint8List bytes,
    required String bucket,
    required String path, // full path in bucket: eg. user_id/filename.ext
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(path, bytes);
      final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('❌ UploadBytes failed: $e');
      return null;
    }
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      print('❌ DeleteFile failed: $e');
    }
  }

  Future<String?> replaceFile({
    required String oldPath,
    required String bucket,
    required Uint8List newBytes,
    required String newPath,
  }) async {
    try {
      // Hapus file lama
      await deleteFile(bucket: bucket, path: oldPath);

      // Upload baru
      final url = await uploadBytes(
        bytes: newBytes,
        bucket: bucket,
        path: newPath,
      );
      return url;
    } catch (e) {
      print('❌ Replace file failed: $e');
      return null;
    }
  }
}
