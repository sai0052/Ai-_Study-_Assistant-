import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_tile.dart';

class TasksListScreen extends ConsumerWidget {
  const TasksListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks & Assignments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: tasksAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => Center(child: Text('Failed to load tasks: $err')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const EmptyState(
              icon: Icons.task_alt_outlined,
              title: 'No tasks yet',
              subtitle: 'Add your first assignment or exam deadline to stay on track.',
            );
          }
          final pending = tasks.where((t) => !t.isCompleted).toList();
          final completed = tasks.where((t) => t.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 80),
            children: [
              if (pending.isNotEmpty) ...[
                Text('Pending (${pending.length})', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...pending.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskTile(
                        task: t,
                        onToggle: (v) => ref.read(tasksControllerProvider).toggleComplete(t.id, v ?? false),
                        onDelete: () => ref.read(tasksControllerProvider).deleteTask(t.id),
                      ),
                    )),
                const SizedBox(height: AppSizes.lg),
              ],
              if (completed.isNotEmpty) ...[
                Text('Completed (${completed.length})', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...completed.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskTile(
                        task: t,
                        onToggle: (v) => ref.read(tasksControllerProvider).toggleComplete(t.id, v ?? false),
                        onDelete: () => ref.read(tasksControllerProvider).deleteTask(t.id),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}
