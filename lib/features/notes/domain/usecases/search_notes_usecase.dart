import '../entities/note_entity.dart';

/// Pure, testable client-side search/filter logic over an already-fetched
/// notes list (Firestore full-text search requires a 3rd-party extension,
/// so for a portfolio app we filter locally — fast for a student's own notes).
class SearchNotesUsecase {
  List<NoteEntity> call(List<NoteEntity> notes, String query) {
    if (query.trim().isEmpty) return notes;
    final lowerQuery = query.toLowerCase();
    return notes
        .where((note) =>
            note.title.toLowerCase().contains(lowerQuery) || note.content.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
