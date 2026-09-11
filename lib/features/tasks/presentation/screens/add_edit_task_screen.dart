import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/tasks_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  const AddEditTaskScreen({super.key});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  TaskPriority _priority = TaskPriority.medium;
  bool _saving = false;

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_deadline));
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time?.hour ?? 23, time?.minute ?? 59);
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      SnackbarHelper.showError(context, 'Please enter a task title');
      return;
    }
    setState(() => _saving = true);
    final failure = await ref.read(tasksControllerProvider).createTask(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          deadline: _deadline,
          priority: _priority,
        );
    setState(() => _saving = false);

    if (failure != null && mounted) {
      SnackbarHelper.showError(context, failure.message);
    } else if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(controller: _titleController, label: 'Task title'),
            const SizedBox(height: AppSizes.md),
            CustomTextField(controller: _descController, label: 'Description (optional)', maxLines: 3),
            const SizedBox(height: AppSizes.md),

            Text('Deadline', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDeadline,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text('${_deadline.toLocal()}'.split('.').first),
            ),
            const SizedBox(height: AppSizes.md),

            Text('Priority', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<TaskPriority>(
              segments: const [
                ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                ButtonSegment(value: TaskPriority.medium, label: Text('Medium')),
                ButtonSegment(value: TaskPriority.high, label: Text('High')),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: AppSizes.xl),

            CustomButton(label: 'Save Task', onPressed: _save, isLoading: _saving),
          ],
        ),
      ),
    );
  }
}
