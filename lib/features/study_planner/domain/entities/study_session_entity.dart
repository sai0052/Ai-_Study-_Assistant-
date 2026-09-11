import 'package:equatable/equatable.dart';

class StudySessionEntity extends Equatable {
  final String id;
  final String ownerId;
  final String subject;
  final DateTime date;
  final int durationMinutes;
  final bool isCompleted;

  const StudySessionEntity({
    required this.id,
    required this.ownerId,
    required this.subject,
    required this.date,
    required this.durationMinutes,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [id, ownerId, subject, date, durationMinutes, isCompleted];
}
