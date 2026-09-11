import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({required String email, required String password});

  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, void>> updateProfile({
    required String uid,
    String? name,
    String? collegeName,
    String? course,
  });
}