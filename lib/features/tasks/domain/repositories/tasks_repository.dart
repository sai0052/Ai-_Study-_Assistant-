import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TasksRepository {
  Stream<List<TaskEntity>> watchTasks(String userId);
  Future<Either<Failure, void>> createTask(TaskEntity task);
  Future<Either<Failure, void>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, void>> toggleComplete(String taskId, bool isCompleted);
}
