import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/tasks_remote_datasource.dart';
import '../models/task_model.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;
  TasksRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<TaskEntity>> watchTasks(String userId) => remoteDataSource.watchTasks(userId);

  @override
  Future<Either<Failure, void>> createTask(TaskEntity task) async {
    try {
      await remoteDataSource.createTask(TaskModel.fromEntity(task));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(TaskEntity task) async {
    try {
      await remoteDataSource.updateTask(TaskModel.fromEntity(task));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await remoteDataSource.deleteTask(taskId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleComplete(String taskId, bool isCompleted) async {
    try {
      await remoteDataSource.toggleComplete(taskId, isCompleted);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
