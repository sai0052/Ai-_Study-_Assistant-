import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../ai_assistant/domain/repositories/ai_repository.dart';
import '../repositories/notes_repository.dart';

/// Combines two repositories: asks the AI for a summary, then persists it
/// on the note document. This is a great example of a usecase that
/// orchestrates across features without those features depending on each other.
class SummarizeNoteUsecase {
  final AiRepository aiRepository;
  final NotesRepository notesRepository;
  SummarizeNoteUsecase(this.aiRepository, this.notesRepository);

  Future<Either<Failure, String>> call({required String noteId, required String content}) async {
    final summaryResult = await aiRepository.summarizeText(content);
    return summaryResult.fold(
      (failure) => Left(failure),
      (summary) async {
        await notesRepository.saveAiSummary(noteId: noteId, summary: summary);
        return Right(summary);
      },
    );
  }
}
