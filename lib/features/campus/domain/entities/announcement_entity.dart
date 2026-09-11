import 'package:equatable/equatable.dart';

enum AnnouncementType { general, event, urgent }

class AnnouncementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final AnnouncementType type;
  final DateTime postedAt;
  final DateTime? eventDate;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.postedAt,
    this.eventDate,
  });

  @override
  List<Object?> get props => [id, title, description, type, postedAt, eventDate];
}
