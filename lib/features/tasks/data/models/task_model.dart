import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.ownerId,
    required super.title,
    super.description,
    required super.deadline,
    required super.priority,
    super.isCompleted,
    required super.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskModel(
      id: doc.id,
      ownerId: data['ownerId'] as String,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      deadline: (data['deadline'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TaskModel.fromEntity(TaskEntity e) => TaskModel(
        id: e.id,
        ownerId: e.ownerId,
        title: e.title,
        description: e.description,
        deadline: e.deadline,
        priority: e.priority,
        isCompleted: e.isCompleted,
        createdAt: e.createdAt,
      );
}
