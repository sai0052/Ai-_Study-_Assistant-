import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ai_repository.dart';

class AskQuestionUsecase {
  final AiRepository repository;
  AskQuestionUsecase(this.repository);

  Future<Either<Failure, String>> call(String question) => repository.askQuestion(question);
}
