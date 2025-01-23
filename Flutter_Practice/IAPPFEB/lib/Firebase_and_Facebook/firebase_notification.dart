import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:open_filex/open_filex.dart';

class ShowPushNotification {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onCLickNotification = BehaviorSubject<String>();
  static Future init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
      BehaviorSubject<String>()
        ..add(details.payload!)
        ..stream.listen((value) async {
          OpenFilex.open(value);
          // final status = await Permission.manageExternalStorage.request();
          // if (status.isGranted) {
          //   // var result = await OpenFile.open(value);
          //   OpenFilex.open(value);
          // }
        });
    });
  }

  static Future showNotification(message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
            ticker: 'ticker');
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: DarwinNotificationDetails());

    if (message is String) {
      List filedir = message.split("/");
      await flutterLocalNotificationsPlugin.show(0, "downloaded sucessfully",
          filedir[filedir.length - 1], notificationDetails,
          payload: message);
    } else {
      message as RemoteMessage;
      var notification = message!.notification;
      await flutterLocalNotificationsPlugin.show(notification.hashCode,
          notification!.title, notification.body, notificationDetails);
    }
  }
}
