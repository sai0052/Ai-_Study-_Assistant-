import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note_entity.dart';

abstract class NotesRepository {
  Stream<List<NoteEntity>> watchNotes(String userId);
  Future<Either<Failure, void>> createNote(NoteEntity note);
  Future<Either<Failure, void>> updateNote(NoteEntity note);
  Future<Either<Failure, void>> deleteNote(String noteId);
  Future<Either<Failure, String>> uploadAttachment({required String userId, required String filePath, required String fileName});
  Future<Either<Failure, void>> saveAiSummary({required String noteId, required String summary});
}
