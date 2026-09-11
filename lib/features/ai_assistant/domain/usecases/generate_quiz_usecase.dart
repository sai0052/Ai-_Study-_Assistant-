import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ai_repository.dart';

class GenerateQuizUsecase {
  final AiRepository repository;
  GenerateQuizUsecase(this.repository);

  Future<Either<Failure, List<String>>> call(String topic, {int questionCount = 5}) {
    return repository.generateQuiz(topic, questionCount: questionCount);
  }
}
