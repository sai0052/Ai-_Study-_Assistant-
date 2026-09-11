import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;
  AiRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> askQuestion(String question) async {
    final prompt =
        'You are a friendly, encouraging academic tutor chatting with a college '
        'student inside a study app. If the message below is just casual '
        'conversation (a greeting, small talk, thanks, etc.), reply naturally '
        'and briefly, like a real conversation — no headers, no tables, no '
        'over-explaining. If it is an actual academic question or asks you to '
        'explain a concept, explain it in simple, clear language with a short '
        'example if useful, keeping it concise rather than exhaustive.\n\n'
        'Message: $question';
    return _safeCall(() => remoteDataSource.generateText(prompt));
  }

  @override
  Future<Either<Failure, String>> continueConversation(List<Map<String, String>> history) async {
    return _safeCall(() => remoteDataSource.generateChatResponse(history));
  }

  @override
  Future<Either<Failure, String>> summarizeText(String text) async {
    final prompt =
        'Summarize the following study material into concise bullet points '
        'a college student can revise from quickly. Keep it under 200 words:\n\n$text';
    return _safeCall(() => remoteDataSource.generateText(prompt));
  }

  @override
  Future<Either<Failure, List<String>>> generateQuiz(String topic, {int questionCount = 5}) async {
    final prompt =
        'Generate exactly $questionCount multiple-choice quiz questions about "$topic" '
        'for a college-level student. Format each question as a numbered line followed by '
        '4 options labeled A-D and mark the correct answer at the end with "Answer: X". '
        'Return plain text only, one question block per item, separated by blank lines.';

    final result = await _safeCall(() => remoteDataSource.generateText(prompt));
    return result.fold(
          (failure) => Left(failure),
          (text) {
        final questions = text.split('\n\n').where((q) => q.trim().isNotEmpty).toList();
        return Right(questions);
      },
    );
  }

  @override
  Future<Either<Failure, String>> studyRecommendation({required List<String> weakTopics}) async {
    final topicsList = weakTopics.isEmpty ? 'general revision' : weakTopics.join(', ');
    final prompt =
        'A college student needs a short, motivating study plan suggestion (max 4 sentences) '
        'focused on improving in: $topicsList. Be specific and actionable.';
    return _safeCall(() => remoteDataSource.generateText(prompt));
  }

  Future<Either<Failure, T>> _safeCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Right(result);
    } on AiException catch (e) {
      return Left(AiFailure(e.message));
    } catch (e) {
      return Left(AiFailure('Unexpected AI error: $e'));
    }
  }
}