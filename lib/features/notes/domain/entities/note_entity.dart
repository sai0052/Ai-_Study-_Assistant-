import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String content;
  final String? aiSummary;
  final String? attachmentUrl;
  final String? attachmentType; // 'pdf' | 'image' | null
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.content,
    this.aiSummary,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, ownerId, title, content, aiSummary, attachmentUrl, attachmentType, createdAt, updatedAt];
}
