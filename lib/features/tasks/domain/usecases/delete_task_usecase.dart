import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tasks_repository.dart';

class DeleteTaskUsecase {
  final TasksRepository repository;
  DeleteTaskUsecase(this.repository);
  Future<Either<Failure, void>> call(String taskId) => repository.deleteTask(taskId);
}
