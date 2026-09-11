import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/ai_remote_datasource.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/utils/file_text_extractor.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/ask_question_usecase.dart';
import '../../domain/usecases/generate_quiz_usecase.dart';
import '../../domain/usecases/summarize_text_usecase.dart';

final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) => GroqRemoteDataSource());
final aiRepositoryProvider = Provider<AiRepository>((ref) => AiRepositoryImpl(ref.watch(aiRemoteDataSourceProvider)));

final askQuestionUsecaseProvider = Provider((ref) => AskQuestionUsecase(ref.watch(aiRepositoryProvider)));
final summarizeTextUsecaseProvider = Provider((ref) => SummarizeTextUsecase(ref.watch(aiRepositoryProvider)));
final generateQuizUsecaseProvider = Provider((ref) => GenerateQuizUsecase(ref.watch(aiRepositoryProvider)));

const String _systemPrompt =
    'You are a friendly, encouraging academic tutor chatting with a college '
    'student inside a study app. If a message is just casual conversation '
    '(a greeting, small talk, thanks, etc.), reply naturally and briefly — '
    'no headers, no tables, no over-explaining. If it is an actual academic '
    'question, explain it in simple, clear language with a short example if '
    'useful, keeping it concise rather than exhaustive. Use the ongoing '
    'conversation history to stay consistent with what has already been '
    'discussed — remember earlier context instead of treating every message '
    'as brand new.';

class AttachedFile {
  final String fileName;
  final String extractedText;
  const AttachedFile({required this.fileName, required this.extractedText});
}

final attachedFileProvider = StateProvider<AttachedFile?>((ref) => null);

class ChatController extends StateNotifier<List<ChatMessageEntity>> {
  final Ref ref;
  final _uuid = const Uuid();
  bool isLoading = false;
  bool isProcessingFile = false;

  ChatController(this.ref) : super([]);

  Future<String?> attachFile({required String filePath, required String fileName}) async {
    isProcessingFile = true;
    state = [...state];

    try {
      final text = await FileTextExtractor.extractText(filePath, fileName);
      ref.read(attachedFileProvider.notifier).state = AttachedFile(fileName: fileName, extractedText: text);

      state = [
        ...state,
        ChatMessageEntity(
          id: _uuid.v4(),
          text: 'Attached "$fileName" — ask me anything about it!',
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ),
      ];
      return null;
    } catch (e) {
      return 'Could not read that file: $e';
    } finally {
      isProcessingFile = false;
      state = [...state];
    }
  }

  void removeAttachedFile() {
    ref.read(attachedFileProvider.notifier).state = null;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessageEntity(
      id: _uuid.v4(),
      text: text.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    final priorMessages = state;
    state = [...state, userMessage];

    isLoading = true;
    state = [...state];

    final messages = _buildRequestMessages(priorMessages: priorMessages, newQuestion: text.trim());

    final result = await ref.read(aiRepositoryProvider).continueConversation(messages);
    isLoading = false;

    result.fold(
          (failure) {
        state = [
          ...state,
          ChatMessageEntity(
            id: _uuid.v4(),
            text: "Sorry, I couldn't process that: ${failure.message}",
            sender: MessageSender.ai,
            timestamp: DateTime.now(),
          ),
        ];
      },
          (answer) {
        state = [
          ...state,
          ChatMessageEntity(id: _uuid.v4(), text: answer, sender: MessageSender.ai, timestamp: DateTime.now()),
        ];
      },
    );
  }

  List<Map<String, String>> _buildRequestMessages({
    required List<ChatMessageEntity> priorMessages,
    required String newQuestion,
  }) {
    final attached = ref.read(attachedFileProvider);

    var systemContent = _systemPrompt;
    if (attached != null) {
      systemContent += '\n\nThe student has attached a document called '
          '"${attached.fileName}". Use it as context when relevant, and say '
          'so if a question can\'t be answered from it:\n\n'
          '--- DOCUMENT START ---\n${attached.extractedText}\n--- DOCUMENT END ---';
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemContent},
    ];

    for (final m in priorMessages) {
      messages.add({
        'role': m.sender == MessageSender.user ? 'user' : 'assistant',
        'content': m.text,
      });
    }

    messages.add({'role': 'user', 'content': newQuestion});
    return messages;
  }

  void clearChat() {
    state = [];
    ref.read(attachedFileProvider.notifier).state = null;
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessageEntity>>((ref) {
  return ChatController(ref);
});