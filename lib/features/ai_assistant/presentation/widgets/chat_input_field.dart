import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final bool isLoading;
  final bool isProcessingFile;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
    this.isLoading = false,
    this.isProcessingFile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            isProcessingFile
                ? const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
                : IconButton(
              onPressed: onAttach,
              icon: const Icon(Icons.attach_file_rounded),
              tooltip: 'Attach a PDF or text file',
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Ask me anything about your studies...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            isLoading
                ? const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.2)),
            )
                : IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}