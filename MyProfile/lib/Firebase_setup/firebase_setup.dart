import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_options.dart';
// import '../screens/NOVOscreens/notificationScreen.dart';
import '../screens/NOVOscreens/notificationScreen.dart';
import '/Roating/route.dart' as route;

final navigatorKey = GlobalKey<NavigatorState>();

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);
bool isFlutterLocalNotificationsInitialized = false;
List firestoreMsg = [];
final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future firebaseInitialSetup() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) => null,
  );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('Notification Tapped!');
      print(response.payload);
      if (response.payload != null) {
        // Navigate to the screen using the payload
        // navigateToNotificationScreen(response.payload!);
      }
    },
  );
}

// Future<void> setupFlutterNotifications() async {
//   if (isFlutterLocalNotificationsInitialized) {
//     return;
//   }
//   channel = const AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.high,
//   );
//   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   isFlutterLocalNotificationsInitialized = true;
// }

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await setupFlutterNotifications();
  await firebaseInitialSetup();
  await getNotification(
      title: message.notification!.title!,
      body: message.notification!.body!,
      messageId: message.sentTime.toString());
  // print(message.data['route']);
  // navigateToNotificationScreen(message.data['route'] ?? '');
}

// void navigateToNotificationScreen(String message) {
//   print("message");
//   print(message);
//   if (message.isNotEmpty) {
//     navigatorKey.currentState?.pushNamed(message);
//   } else {
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(
//         builder: (context) => NotificationScreen(),
//       ),
//     );
//   }
//   // navigatorKey.currentState?.push(
//   //   MaterialPageRoute(
//   //     builder: (context) => NotificationScreen(),
//   //   ),
//   // );
//   // String routename=message;
// }

Future<void> handleMessage(RemoteMessage message) async {
  // firebaseInitialSetup();
  final notification = message.notification;

//** This variable is not used but dont remove this variable for initalize the notifications values..
  String res = notification!.title!;
  String resbody = notification.body!;
  final String routeFromMessage = message.data['route'] ?? "";

  await getNotification(
      title: notification.title!,
      body: message.notification!.body!,
      messageId: message.sentTime.toString());
  // navigateToNotificationScreen(message);

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    payload: routeFromMessage,
    NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails()),
  );
}

Future<List<Map<String, dynamic>>> load() async {
  List<Map<String, dynamic>> msg = [];
  try {
    var collectionRef = firestore.collection('global_Messages');
    var collectionSnapshot = await collectionRef.get();

    if (collectionSnapshot.docs.isNotEmpty) {
      var docSnapshot = await collectionRef.doc('Notifications').get();
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('message')) {
        msg = List<Map<String, dynamic>>.from(docSnapshot.get('message'));
      } else {
        await collectionRef.doc('Notifications').set({'message': []});
      }
    } else {
      await collectionRef.doc('Notifications').set({'message': []});
      msg = [];
    }
  } catch (e) {
    ////print('Error loading data from Firestore: $e');
  }

  return msg;
}

Future<String> getNotification(
    {required String title,
    required String body,
    required String messageId}) async {
  firestoreMsg = await load();
  List msgId = [];
  for (var message in firestoreMsg) {
    msgId.add(message['id']);
  }
  if (!msgId.contains(messageId)) {
    firestoreMsg.add({"title": title, 'body': body, 'id': messageId});
  }
  String res = 'Some Error Occured';
  try {
    await firestore
        .collection('global_Messages')
        .doc('Notifications')
        .update({"message": firestoreMsg});
    res = 'success';
  } catch (e) {
    res = e.toString();
  }
  return res;
}
