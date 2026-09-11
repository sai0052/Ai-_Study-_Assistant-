import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase Cloud Messaging setup: permission requests, token
/// retrieval (to store against the user's Firestore profile so a backend
/// can target them), and foreground message handling.
///
/// Wire this up once in main.dart after Firebase.initializeApp():
///   final fcm = FcmService();
///   await fcm.initialize();
class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Ask the user for notification permission (required on iOS, and
    //    Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM: user denied notification permission');
      return;
    }

    // 2. Get the device token — save this to the user's Firestore document
    //    (users/{uid}.fcmToken) so a Cloud Function can send them targeted
    //    reminders (e.g. "Assignment due in 1 hour").
    final token = await _messaging.getToken();
    debugPrint('FCM device token: $token');

    // 3. Handle a message that arrives while the app is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground FCM message: ${message.notification?.title}');
      // TODO: show an in-app banner/snackbar using message.notification
    });

    // 4. Handle the user tapping a notification that opened the app from
    //    the background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped, opened app: ${message.data}');
      // TODO: use GoRouter to deep-link into the relevant screen,
      // e.g. context.push('/tasks') if message.data['type'] == 'task_reminder'
    });
  }

  /// Call this whenever a task/session is created with a deadline, to sync
  /// a local reminder. For production-grade scheduled push notifications,
  /// pair this with a Cloud Function + Cloud Scheduler that reads upcoming
  /// deadlines from Firestore and calls the FCM Admin SDK.
  Future<String?> getDeviceToken() => _messaging.getToken();
}

/// Must be a top-level function (not a class method) — this is the entry
/// point Firebase calls when a push notification arrives while the app is
/// fully terminated. Register it in main.dart via
/// FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM message: ${message.messageId}');
}
