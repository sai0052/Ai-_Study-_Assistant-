import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/tasks_remote_datasource.dart';
import '../../data/repositories/tasks_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/toggle_complete_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

final tasksRemoteDataSourceProvider = Provider<TasksRemoteDataSource>((ref) {
  return TasksRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepositoryImpl(ref.watch(tasksRemoteDataSourceProvider));
});

final createTaskUsecaseProvider = Provider((ref) => CreateTaskUsecase(ref.watch(tasksRepositoryProvider)));
final updateTaskUsecaseProvider = Provider((ref) => UpdateTaskUsecase(ref.watch(tasksRepositoryProvider)));
final deleteTaskUsecaseProvider = Provider((ref) => DeleteTaskUsecase(ref.watch(tasksRepositoryProvider)));
final toggleCompleteUsecaseProvider = Provider((ref) => ToggleCompleteUsecase(ref.watch(tasksRepositoryProvider)));

/// Live stream of the current user's tasks.
final tasksStreamProvider = StreamProvider<List<TaskEntity>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(tasksRepositoryProvider).watchTasks(user.uid);
});

/// Derived provider: only today's incomplete tasks — used on the Dashboard.
final todaysTasksProvider = Provider<List<TaskEntity>>((ref) {
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  final now = DateTime.now();
  return tasks.where((t) {
    final d = t.deadline;
    return !t.isCompleted && d.year == now.year && d.month == now.month && d.day == now.day;
  }).toList();
});

/// Derived provider: next 7 days of deadlines — used on the Dashboard.
final upcomingDeadlinesProvider = Provider<List<TaskEntity>>((ref) {
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  final now = DateTime.now();
  final weekFromNow = now.add(const Duration(days: 7));
  return tasks.where((t) => !t.isCompleted && t.deadline.isAfter(now) && t.deadline.isBefore(weekFromNow)).toList();
});

class TasksController {
  final Ref ref;
  final _uuid = const Uuid();
  TasksController(this.ref);

  Future<Failure?> createTask({
    required String title,
    String? description,
    required DateTime deadline,
    required TaskPriority priority,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return const AuthFailure('You must be signed in');

    final task = TaskEntity(
      id: _uuid.v4(),
      ownerId: user.uid,
      title: title,
      description: description,
      deadline: deadline,
      priority: priority,
      createdAt: DateTime.now(),
    );
    final result = await ref.read(createTaskUsecaseProvider).call(task);
    return result.fold((f) => f, (_) => null);
  }

  Future<void> toggleComplete(String taskId, bool isCompleted) async {
    await ref.read(toggleCompleteUsecaseProvider).call(taskId, isCompleted);
  }

  Future<void> deleteTask(String taskId) async {
    await ref.read(deleteTaskUsecaseProvider).call(taskId);
  }
}

final tasksControllerProvider = Provider((ref) => TasksController(ref));
