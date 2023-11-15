import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationHelper() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings(
          '@mipmap/ic_launcher'), // Use the actual icon resource ID
      iOS: IOSInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future<void> showNotification(String title, String body) async {
    await initializeNotifications(); // Ensure initialization before using

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle notification click here
    print('Notification clicked with payload: $payload');
  }
}
