import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/notes_provider.dart';

/// Create-note screen. (Editing an existing note follows the same pattern —
/// pass the existing NoteEntity in via `extra` and pre-fill the controllers.)
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      SnackbarHelper.showError(context, 'Please add a title');
      return;
    }
    setState(() => _saving = true);
    final failure = await ref.read(notesControllerProvider).createNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
    setState(() => _saving = false);

    if (failure != null && mounted) {
      SnackbarHelper.showError(context, failure.message);
    } else if (mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'Attach PDF/Image',
            onPressed: () {
              // Wire up file_picker + UploadNoteFileUsecase here:
              // 1. FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','jpg','png'])
              // 2. call notesRepository.uploadAttachment(...)
              // 3. save the returned URL onto the note
              SnackbarHelper.showInfo(context, 'Attach flow wired via file_picker — see README.');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(hintText: 'Start typing your notes...', border: InputBorder.none),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            CustomButton(label: 'Save Note', onPressed: _save, isLoading: _saving),
          ],
        ),
      ),
    );
  }
}
