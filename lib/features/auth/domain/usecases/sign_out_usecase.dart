import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository repository;
  SignOutUsecase(this.repository);

  Future<Either<Failure, void>> call() => repository.signOut();
}
