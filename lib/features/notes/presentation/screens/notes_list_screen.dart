import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesStreamProvider);
    final filteredNotes = ref.watch(filteredNotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/notes/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: TextField(
              onChanged: (value) => ref.read(notesSearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: notesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => Center(child: Text('Failed to load notes: $err')),
              data: (_) {
                if (filteredNotes.isEmpty) {
                  return const EmptyState(
                    icon: Icons.note_alt_outlined,
                    title: 'No notes yet',
                    subtitle: 'Tap "New Note" to capture your first lecture notes or upload a PDF.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, 80),
                  itemCount: filteredNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) => NoteCard(note: filteredNotes[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
