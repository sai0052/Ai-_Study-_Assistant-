import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ai_repository.dart';

class SummarizeTextUsecase {
  final AiRepository repository;
  SummarizeTextUsecase(this.repository);

  Future<Either<Failure, String>> call(String text) => repository.summarizeText(text);
}
