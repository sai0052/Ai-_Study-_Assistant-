import 'package:dio/dio.dart';
import '../../../../config/env/env.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';

abstract class AiRemoteDataSource {
  Future<String> generateText(String prompt);

  /// Multi-turn chat call: sends the full conversation history so the AI
  /// has real memory across the chat instead of treating every message as
  /// a brand-new, isolated question. `messages` is a list of
  /// {'role': 'system'|'user'|'assistant', 'content': '...'} maps, in order.
  Future<String> generateChatResponse(List<Map<String, String>> messages);
}

class GroqRemoteDataSource implements AiRemoteDataSource {
  final ApiClient apiClient;

  static const String _model = 'openai/gpt-oss-20b';

  GroqRemoteDataSource({ApiClient? client})
      : apiClient = client ?? ApiClient(baseUrl: 'https://api.groq.com/openai/v1');

  @override
  Future<String> generateText(String prompt) async {
    return generateChatResponse([
      {'role': 'user', 'content': prompt}
    ]);
  }

  @override
  Future<String> generateChatResponse(List<Map<String, String>> messages) async {
    try {
      final response = await apiClient.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        },
        headers: {
          'Authorization': 'Bearer ${Env.groqApiKey}',
        },
      );

      final choices = response.data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw AiException('The AI returned no response. Try rephrasing your question.');
      }

      final text = choices[0]['message']?['content'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw AiException('The AI returned an empty response.');
      }
      return text.trim();
    } on DioException catch (e) {
      final message = e.response?.data?['error']?['message'] ?? e.message;
      throw AiException('AI request failed: $message');
    }
  }
}

class OxAlphaRemoteDataSource implements AiRemoteDataSource {
  final ApiClient apiClient;

  static const String _model = 'stealth/ox-alpha';

  OxAlphaRemoteDataSource({ApiClient? client})
      : apiClient = client ?? ApiClient(baseUrl: 'https://openrouter.ai/api/v1');

  @override
  Future<String> generateText(String prompt) async {
    return generateChatResponse([
      {'role': 'user', 'content': prompt}
    ]);
  }

  @override
  Future<String> generateChatResponse(List<Map<String, String>> messages) async {
    try {
      final response = await apiClient.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        },
        headers: {
          'Authorization': 'Bearer ${Env.openRouterApiKey}',
          'HTTP-Referer': 'https://ai-student-assistant.app',
          'X-Title': 'AI Student Assistant',
        },
      );

      final choices = response.data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw AiException('The AI returned no response. Try rephrasing your question.');
      }

      final text = choices[0]['message']?['content'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw AiException('The AI returned an empty response.');
      }
      return text.trim();
    } on DioException catch (e) {
      final message = e.response?.data?['error']?['message'] ?? e.message;
      throw AiException('AI request failed: $message');
    }
  }
}