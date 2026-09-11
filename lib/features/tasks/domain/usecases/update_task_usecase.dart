import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class UpdateTaskUsecase {
  final TasksRepository repository;
  UpdateTaskUsecase(this.repository);
  Future<Either<Failure, void>> call(TaskEntity task) => repository.updateTask(task);
}
