import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  static initlizeLocalNotification(GlobalKey<NavigatorState> navigatorKey) {
    const androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
    const initializationSettings = InitializationSettings(android: androidInit);
    _flutterLocalNotificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        debugPrint("Notification tapped with payload: ${details.payload}");
      },
    );
  }

  static requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("User granted provisional permission");
    } else {
      debugPrint("User denied permission");
    }

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static showNotification(RemoteMessage event) async {
    debugPrint(event.data.toString());
    Random random = Random();
    int id = random.nextInt(1000);

    if (Platform.isAndroid) {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        event.notification?.body ?? '',
        htmlFormatBigText: true,
        contentTitle: event.notification?.title ?? '',
        htmlFormatContentTitle: true,
      );

      var androidNotificationDetails = AndroidNotificationDetails(
        "com.hunt30.coyotex",
        "Coyotex",
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        color: Colors.blue,
        playSound: true,
        enableLights: true,
        enableVibration: true,
        ticker: 'ticker',
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _flutterLocalNotificationPlugin.show(
        id,
        event.notification?.title,
        event.notification?.body,
        notificationDetails,
        payload: event.data['type'].toString(),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      var darwinNotificationDetails = const DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        iOS: darwinNotificationDetails,
        macOS: darwinNotificationDetails,
      );

      await _flutterLocalNotificationPlugin.show(
        id,
        event.notification?.title,
        event.notification?.body,
        notificationDetails,
        payload: "Text",
      );
    }
  }

  messageInit(GlobalKey<NavigatorState> navigatorKey) async {
    initlizeLocalNotification(navigatorKey);
    requestPermission();

    await FirebaseMessaging.instance.getInitialMessage().then((event) async {
      if (event != null) {
        await showNotification(event);
        debugPrint(event.toString());
      }
    });

    FirebaseMessaging.onMessage.listen((event) async {
      await showNotification(event);
      debugPrint(event.notification?.title);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      await showNotification(event);
      debugPrint(event.notification?.title);
    });
  }

  static Future<String?> getDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint("Push notifications permission denied.");
        return null;
      }

      String? token = await messaging.getToken();
      debugPrint("FCM Device Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting device token: $e");
      return null;
    }
  }

  /// Trigger test notification manually
static Future<void> triggerTestNotification({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'test_channel_id',
    'Test Notifications',
    channelDescription: 'Channel for testing',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await _flutterLocalNotificationPlugin.show(
    1001, // notification ID
    title,
    body,
    details,
    payload: 'test_payload',
  );
}

}
