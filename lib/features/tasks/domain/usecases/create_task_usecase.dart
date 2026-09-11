import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class CreateTaskUsecase {
  final TasksRepository repository;
  CreateTaskUsecase(this.repository);
  Future<Either<Failure, void>> call(TaskEntity task) => repository.createTask(task);
}
