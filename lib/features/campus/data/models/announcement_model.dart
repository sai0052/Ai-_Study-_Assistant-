import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.postedAt,
    super.eventDate,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AnnouncementModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: AnnouncementType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => AnnouncementType.general,
      ),
      postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventDate: (data['eventDate'] as Timestamp?)?.toDate(),
    );
  }
}
