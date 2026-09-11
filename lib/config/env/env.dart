import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Single access point for all secret/config values.
/// Never call `dotenv.env['X']` anywhere else in the app — always go through
/// this class, so if the loading mechanism changes (e.g. to --dart-define or
/// a remote config service) only this file needs to change.
class Env {
  Env._();

  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get aiProxyBaseUrl => dotenv.env['AI_PROXY_BASE_URL'] ?? '';

  /// Toggle this to true once you move AI calls behind a Cloud Function,
  /// so the raw API key never ships inside the client app.
  static const bool useServerProxy = false;
}