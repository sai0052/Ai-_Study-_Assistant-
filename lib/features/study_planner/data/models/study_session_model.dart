import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/study_session_entity.dart';

class StudySessionModel extends StudySessionEntity {
  const StudySessionModel({
    required super.id,
    required super.ownerId,
    required super.subject,
    required super.date,
    required super.durationMinutes,
    super.isCompleted,
  });

  factory StudySessionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StudySessionModel(
      id: doc.id,
      ownerId: data['ownerId'] as String,
      subject: data['subject'] as String,
      date: (data['date'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] as int? ?? 25,
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'subject': subject,
        'date': Timestamp.fromDate(date),
        'durationMinutes': durationMinutes,
        'isCompleted': isCompleted,
      };
}
