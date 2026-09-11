import 'package:equatable/equatable.dart';

/// Pure domain representation of a user. No Firebase types leak in here —
/// that's what makes this layer independent of the backend.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String? collegeName;
  final String? course;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.collegeName,
    this.course,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, email, name, collegeName, course, photoUrl];
}
