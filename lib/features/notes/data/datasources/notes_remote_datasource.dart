import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Stream<List<NoteModel>> watchNotes(String userId);
  Future<void> createNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String noteId);
  Future<void> saveAiSummary({required String noteId, required String summary});
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final FirebaseFirestore firestore;
  NotesRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _notes => firestore.collection('notes');

  @override
  Stream<List<NoteModel>> watchNotes(String userId) {
    return _notes
        .where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(NoteModel.fromFirestore).toList());
  }

  @override
  Future<void> createNote(NoteModel note) async {
    try {
      await _notes.doc(note.id).set(note.toMap());
    } catch (e) {
      throw ServerException('Failed to create note: $e');
    }
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    try {
      await _notes.doc(note.id).update(note.toMap());
    } catch (e) {
      throw ServerException('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    try {
      await _notes.doc(noteId).delete();
    } catch (e) {
      throw ServerException('Failed to delete note: $e');
    }
  }

  @override
  Future<void> saveAiSummary({required String noteId, required String summary}) async {
    await _notes.doc(noteId).update({'aiSummary': summary});
  }
}
