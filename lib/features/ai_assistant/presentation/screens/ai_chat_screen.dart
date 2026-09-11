import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/chat_provider.dart';
import '../widgets/attached_file_chip.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    ref.read(chatControllerProvider.notifier).sendMessage(text);
    _textController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleAttach() async {
    // file_picker opens the native file browser — restricted to PDF/text
    // since that's what FileTextExtractor knows how to read.
    // file_picker v12 moved to a federated plugin architecture:
    // FilePicker.pickFile() is a static call (no more `.platform`) and
    // returns a nullable PlatformFile directly — null if the user cancels.
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md'],
    );
    if (file == null) return;

    final path = file.path;
    if (path == null) {
      if (mounted) SnackbarHelper.showError(context, 'Could not access that file.');
      return;
    }

    final error = await ref.read(chatControllerProvider.notifier).attachFile(
      filePath: path,
      fileName: file.name,
    );
    if (error != null && mounted) {
      SnackbarHelper.showError(context, error);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider);
    final isLoading = ref.watch(chatControllerProvider.notifier).isLoading;
    final isProcessingFile = ref.watch(chatControllerProvider.notifier).isProcessingFile;
    final attachedFile = ref.watch(attachedFileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear chat',
            onPressed: () => ref.read(chatControllerProvider.notifier).clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const EmptyState(
              icon: Icons.smart_toy_outlined,
              title: 'Ask your AI tutor anything',
              subtitle:
              'Explain a concept, summarize notes, generate a quiz, or attach a PDF/text file and ask questions about it.',
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) => ChatBubble(message: messages[index]),
            ),
          ),
          if (attachedFile != null)
            AttachedFileChip(
              fileName: attachedFile.fileName,
              onRemove: () => ref.read(chatControllerProvider.notifier).removeAttachedFile(),
            ),
          ChatInputField(
            controller: _textController,
            onSend: _handleSend,
            onAttach: _handleAttach,
            isLoading: isLoading,
            isProcessingFile: isProcessingFile,
          ),
        ],
      ),
    );
  }
}