import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

handleMessage(RemoteMessage? message) {
  if (message == null) return;
}

Future initLocalNotifications() async {
  const android = AndroidInitializationSettings('@drawable/ic_launcher');
  const settings = InitializationSettings(android: android);
  await _localNotification.initialize(settings);

  final platform = _localNotification.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await platform?.createNotificationChannel(_androidChannel);
}

Future initPushNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    if (notification == null) return;
    _localNotification.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
            _androidChannel.id, _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher'),
      ),
      payload: jsonEncode(message.toMap()),
    );
  });
}

void sendNotification(String fcmToken, String title, String message) async {
  print("sending notification to : " + fcmToken);
  const String serverToken =
      "AAAAbf9ELkA:APA91bF0I4hkxCmNWTCyOIuHoo-JLKMyuZNV80Q25AKmGEpc5uFCr7rUg41yC7kBW7So_jgJiEQPB_GG6YM7ODexeDhOFt32Q6892IAxQuBgJx0qkuKYZ5QiCmcWwra3XhSoalZcTZHm"; // Replace with your server token from Firebase Console.
  const String postUrl = 'https://fcm.googleapis.com/fcm/send';

  final headers = <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverToken',
  };

  final body = jsonEncode({
    'notification': {
      'title': title,
      'body': message,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    },
    // 'to':
    //     '/topics/all', // Send to a topic, specific device token, or group of tokens.
    'to': fcmToken, // Send to a specific device token.
  });

  // Send the notification using an HTTP POST request.
  final response =
      await http.post(Uri.parse(postUrl), headers: headers, body: body);

  if (response.statusCode == 200) {
    print("Notification sent successfully!");
  } else {
    print("Failed to send notification. Status code: ${response.statusCode}");
  }
}

Future<void> handleBackgroundMessage(RemoteMessage msg) async {
  print('Title: ${msg.notification?.title}');
  print('Body: ${msg.notification?.body}');
  print('Payload: ${msg.data}');
}

const _androidChannel = AndroidNotificationChannel(
    "high_importance_channel", "High Importance Notifications",
    description: "This channel is used for important Notifications",
    importance: Importance.defaultImportance);
final _localNotification = FlutterLocalNotificationsPlugin();

class FirebaseApi {
  // final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // await _firebaseMessaging.requestPermission();

    // final fCMToken = await _firebaseMessaging.getToken();
    // print("Token: $fCMToken");
    initPushNotifications();
    initLocalNotifications();
  }
}
