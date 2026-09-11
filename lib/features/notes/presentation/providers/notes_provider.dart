import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../ai_assistant/presentation/providers/chat_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notes_remote_datasource.dart';
import '../../data/datasources/notes_storage_datasource.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/search_notes_usecase.dart';
import '../../domain/usecases/summarize_note_usecase.dart';

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

final notesRemoteDataSourceProvider = Provider<NotesRemoteDataSource>((ref) {
  return NotesRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

final notesStorageDataSourceProvider = Provider<NotesStorageDataSource>((ref) {
  return NotesStorageDataSourceImpl(ref.watch(firebaseStorageProvider));
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl(ref.watch(notesRemoteDataSourceProvider), ref.watch(notesStorageDataSourceProvider));
});

final createNoteUsecaseProvider = Provider((ref) => CreateNoteUsecase(ref.watch(notesRepositoryProvider)));
final summarizeNoteUsecaseProvider = Provider(
  (ref) => SummarizeNoteUsecase(ref.watch(aiRepositoryProvider), ref.watch(notesRepositoryProvider)),
);
final searchNotesUsecaseProvider = Provider((ref) => SearchNotesUsecase());

/// Live stream of the current user's notes, ordered by most recently updated.
final notesStreamProvider = StreamProvider<List<NoteEntity>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(notesRepositoryProvider).watchNotes(user.uid);
});

/// Search query state driving the filtered notes list on the Notes screen.
final notesSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredNotesProvider = Provider<List<NoteEntity>>((ref) {
  final notes = ref.watch(notesStreamProvider).value ?? [];
  final query = ref.watch(notesSearchQueryProvider);
  return ref.watch(searchNotesUsecaseProvider).call(notes, query);
});

class NotesController {
  final Ref ref;
  final _uuid = const Uuid();
  NotesController(this.ref);

  Future<Failure?> createNote({required String title, required String content}) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return const AuthFailure('You must be signed in');

    final now = DateTime.now();
    final note = NoteEntity(
      id: _uuid.v4(),
      ownerId: user.uid,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    final result = await ref.read(createNoteUsecaseProvider).call(note);
    return result.fold((failure) => failure, (_) => null);
  }

  Future<Either1> summarize({required String noteId, required String content}) async {
    final result = await ref.read(summarizeNoteUsecaseProvider).call(noteId: noteId, content: content);
    return result.fold((f) => Either1(failure: f), (summary) => Either1(summary: summary));
  }
}

/// Tiny helper wrapper so the UI doesn't need to import dartz.Either directly.
class Either1 {
  final Failure? failure;
  final String? summary;
  Either1({this.failure, this.summary});
}

final notesControllerProvider = Provider((ref) => NotesController(ref));
