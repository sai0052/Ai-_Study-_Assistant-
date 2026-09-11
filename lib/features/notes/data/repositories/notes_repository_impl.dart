import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_datasource.dart';
import '../datasources/notes_storage_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;
  final NotesStorageDataSource storageDataSource;

  NotesRepositoryImpl(this.remoteDataSource, this.storageDataSource);

  @override
  Stream<List<NoteEntity>> watchNotes(String userId) => remoteDataSource.watchNotes(userId);

  @override
  Future<Either<Failure, void>> createNote(NoteEntity note) async {
    try {
      await remoteDataSource.createNote(NoteModel.fromEntity(note));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateNote(NoteEntity note) async {
    try {
      await remoteDataSource.updateNote(NoteModel.fromEntity(note));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await remoteDataSource.deleteNote(noteId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAttachment({
    required String userId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final url = await storageDataSource.uploadFile(userId: userId, filePath: filePath, fileName: fileName);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveAiSummary({required String noteId, required String summary}) async {
    try {
      await remoteDataSource.saveAiSummary(noteId: noteId, summary: summary);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
