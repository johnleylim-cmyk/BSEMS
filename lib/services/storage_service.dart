import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Firebase Storage service for uploading images.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Upload image bytes and return the download URL.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String path,
    String? fileName,
  }) async {
    final name = fileName ?? '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child(path).child(name);

    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(bytes, metadata);

    return await ref.getDownloadURL();
  }

  /// Delete an image by its download URL.
  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Silently fail if image doesn't exist
    }
  }
}
