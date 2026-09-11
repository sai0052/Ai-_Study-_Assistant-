import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/notes_provider.dart';

/// Shows a single note with a one-tap "Summarize with AI" action —
/// demonstrates the cross-feature usecase (Notes + AI Assistant) in the UI.
class NoteDetailScreen extends ConsumerStatefulWidget {
  final NoteEntity note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  bool _summarizing = false;
  String? _summary;

  Future<void> _summarize() async {
    setState(() => _summarizing = true);
    final result = await ref.read(notesControllerProvider).summarize(
          noteId: widget.note.id,
          content: widget.note.content,
        );
    setState(() {
      _summarizing = false;
      _summary = result.summary;
    });
    if (result.failure != null && mounted) {
      SnackbarHelper.showError(context, result.failure!.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = _summary ?? widget.note.aiSummary;

    return Scaffold(
      appBar: AppBar(title: Text(widget.note.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('AI Summary', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                    ]),
                    const SizedBox(height: 8),
                    Text(summary),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
            Text('Full Note', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(widget.note.content, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _summarizing ? null : _summarize,
        icon: _summarizing
            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.auto_awesome),
        label: Text(_summarizing ? 'Summarizing...' : 'Summarize with AI'),
      ),
    );
  }
}
