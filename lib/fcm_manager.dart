import 'dart:convert';
import 'dart:developer';

import 'package:HeartOfExperian/DataAccessLayer/UserDAO.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification.dart';

class FirebaseMessagingManager {
  static Future<void> initializeFirebaseMessaging() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await UserDAO().updateUserToken(
          FirebaseAuth.instance.currentUser!.uid, fcmToken);
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    //This function gets triggered when we receive background notification only i.e when app is terminated
    // or is in background
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      log('FCM Token (Refreshed): $newToken');
      await UserDAO().updateUserToken(
          FirebaseAuth.instance.currentUser!.uid, newToken);
    });

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        if (message != null) {
          log("CalledNotificationOnTerminated: ${message.data}");
          NotificationService.checkNotificationType(jsonEncode(message.data));
        }
      },
    );

    FirebaseMessaging.onMessage.listen((message) {
      log("CalledNotificationOnForeground: ${message.data}");
      NotificationService().showNotificationMediaStyle(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        log("CalledNotificationOnBackground: ${message.data}");
        NotificationService().showNotificationMediaStyle(message);
      },
    );
  }

  static Future<dynamic> _backgroundMessageHandler(
      RemoteMessage message) async {
    log("Silent notification received for sync step: ${message.data}");
    NotificationService().showNotificationMediaStyle(message);
  }
}
