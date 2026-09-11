import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.content,
    super.aiSummary,
    super.attachmentUrl,
    super.attachmentType,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NoteModel(
      id: doc.id,
      ownerId: data['ownerId'] as String,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      aiSummary: data['aiSummary'] as String?,
      attachmentUrl: data['attachmentUrl'] as String?,
      attachmentType: data['attachmentType'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'content': content,
      'aiSummary': aiSummary,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory NoteModel.fromEntity(NoteEntity e) => NoteModel(
        id: e.id,
        ownerId: e.ownerId,
        title: e.title,
        content: e.content,
        aiSummary: e.aiSummary,
        attachmentUrl: e.attachmentUrl,
        attachmentType: e.attachmentType,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}
