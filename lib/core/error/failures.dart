import 'package:equatable/equatable.dart';

/// Failures are the "safe" representation of errors passed up from the
/// data layer to the UI. The presentation layer should NEVER catch raw
/// FirebaseException / DioException directly — repositories convert them
/// into a Failure first. This keeps UI code backend-agnostic.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class AiFailure extends Failure {
  const AiFailure([super.message = 'The AI service could not process this request.']);
}
