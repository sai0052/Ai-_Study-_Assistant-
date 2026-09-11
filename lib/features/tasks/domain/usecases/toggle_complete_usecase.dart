import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tasks_repository.dart';

class ToggleCompleteUsecase {
  final TasksRepository repository;
  ToggleCompleteUsecase(this.repository);
  Future<Either<Failure, void>> call(String taskId, bool isCompleted) => repository.toggleComplete(taskId, isCompleted);
}
