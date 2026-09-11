import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Each usecase = one single business action. This keeps providers/screens
/// thin: they call `signInUsecase(email, password)` instead of knowing
/// anything about how sign-in is actually implemented.
class SignInUsecase {
  final AuthRepository repository;
  SignInUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}
