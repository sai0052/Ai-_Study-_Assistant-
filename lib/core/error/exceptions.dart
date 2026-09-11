/// Raw exceptions thrown by the data layer (datasources). These get caught
/// by repository implementations and converted into Failure objects before
/// reaching the domain/presentation layers.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication error']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error']);
}

class AiException implements Exception {
  final String message;
  AiException([this.message = 'AI service error']);
}
