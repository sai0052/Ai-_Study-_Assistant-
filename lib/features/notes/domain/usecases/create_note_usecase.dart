import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class CreateNoteUsecase {
  final NotesRepository repository;
  CreateNoteUsecase(this.repository);
  Future<Either<Failure, void>> call(NoteEntity note) => repository.createNote(note);
}
