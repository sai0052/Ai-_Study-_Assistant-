import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notes_repository.dart';

class UploadNoteFileUsecase {
  final NotesRepository repository;
  UploadNoteFileUsecase(this.repository);
  Future<Either<Failure, String>> call({required String userId, required String filePath, required String fileName}) {
    return repository.uploadAttachment(userId: userId, filePath: filePath, fileName: fileName);
  }
}
