import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUsecase {
  final AuthRepository repository;
  GoogleSignInUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call() => repository.signInWithGoogle();
}
