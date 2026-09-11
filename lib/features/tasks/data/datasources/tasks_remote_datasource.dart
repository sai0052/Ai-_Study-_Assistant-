import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TasksRemoteDataSource {
  Stream<List<TaskModel>> watchTasks(String userId);
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<void> toggleComplete(String taskId, bool isCompleted);
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final FirebaseFirestore firestore;
  TasksRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _tasks => firestore.collection('tasks');

  @override
  Stream<List<TaskModel>> watchTasks(String userId) {
    return _tasks
        .where('ownerId', isEqualTo: userId)
        .orderBy('deadline')
        .snapshots()
        .map((snap) => snap.docs.map(TaskModel.fromFirestore).toList());
  }

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _tasks.doc(task.id).set(task.toMap());
    } catch (e) {
      throw ServerException('Failed to create task: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasks.doc(task.id).update(task.toMap());
    } catch (e) {
      throw ServerException('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasks.doc(taskId).delete();
    } catch (e) {
      throw ServerException('Failed to delete task: $e');
    }
  }

  @override
  Future<void> toggleComplete(String taskId, bool isCompleted) async {
    try {
      await _tasks.doc(taskId).update({'isCompleted': isCompleted});
    } catch (e) {
      throw ServerException('Failed to update task: $e');
    }
  }
}
