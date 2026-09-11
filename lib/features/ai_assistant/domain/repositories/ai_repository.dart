import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AiRepository {
  Future<Either<Failure, String>> askQuestion(String question);

  /// Multi-turn version used by the chat screen: `history` holds the prior
  /// exchanges as {'role', 'content'} maps so the AI has real memory across
  /// the conversation instead of answering each message in isolation.
  Future<Either<Failure, String>> continueConversation(List<Map<String, String>> history);

  Future<Either<Failure, String>> summarizeText(String text);
  Future<Either<Failure, List<String>>> generateQuiz(String topic, {int questionCount = 5});
  Future<Either<Failure, String>> studyRecommendation({required List<String> weakTopics});
}