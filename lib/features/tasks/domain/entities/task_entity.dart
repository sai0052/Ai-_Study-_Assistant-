import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

class TaskEntity extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final DateTime deadline;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
  });

  TaskEntity copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return TaskEntity(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, ownerId, title, description, deadline, priority, isCompleted, createdAt];
}
