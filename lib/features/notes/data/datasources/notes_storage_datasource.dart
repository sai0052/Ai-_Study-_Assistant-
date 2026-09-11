import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/error/exceptions.dart';

/// Handles uploading note attachments (PDFs / images) to Firebase Storage.
/// Kept separate from the Firestore datasource since it's a different
/// Firebase product with a different API surface.
abstract class NotesStorageDataSource {
  Future<String> uploadFile({required String userId, required String filePath, required String fileName});
}

class NotesStorageDataSourceImpl implements NotesStorageDataSource {
  final FirebaseStorage storage;
  NotesStorageDataSourceImpl(this.storage);

  @override
  Future<String> uploadFile({required String userId, required String filePath, required String fileName}) async {
    try {
      final ref = storage.ref().child('notes/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      final uploadTask = await ref.putFile(File(filePath));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw ServerException('File upload failed: $e');
    }
  }
}
