import '../../domain/entities/user_entity.dart';

/// Data-layer model: knows how to convert to/from Firestore's Map format.
/// Extends the domain entity so it can be passed anywhere a UserEntity is
/// expected, while adding serialization logic the domain layer shouldn't know about.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    super.collegeName,
    super.course,
    super.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String? ?? '',
      collegeName: map['collegeName'] as String?,
      course: map['course'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'collegeName': collegeName,
      'course': course,
      'photoUrl': photoUrl,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        uid: entity.uid,
        email: entity.email,
        name: entity.name,
        collegeName: entity.collegeName,
        course: entity.course,
        photoUrl: entity.photoUrl,
      );
}
