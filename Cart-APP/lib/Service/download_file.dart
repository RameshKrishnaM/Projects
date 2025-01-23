import 'dart:io';
import 'dart:typed_data';

import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Firebase_and_Facebook/firebase_notification.dart';

downloadFile(title, Uint8List bytes, fileName, context) async {
  try {
    List l = fileName.toString().split(".");
    Directory? dir;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      dir = await getDownloadsDirectory();
      Directory path = Directory("/storage/emulated/0/Download");

      !path.existsSync() ? await path.create(recursive: true) : null;
      dir = path;
    }
    File file = File("${dir!.path}/$title.${l[l.length - 1]}");

    if (file.existsSync()) {
      for (int i = 1; true; i++) {
        File file1 = File("${dir.path}/$title($i).${l[l.length - 1]}");
        if (!file1.existsSync()) {
          file = file1;
          break;
        }
      }
    }
    file.writeAsBytesSync(bytes);

    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted || Platform.isIOS) {
      ShowPushNotification.showNotification(file.path);
    } else {
      showSnackbar(context, "downloaded sucessfully", Colors.green);
    }
  } catch (e) {
    showSnackbar(context, "some thing went wrong", Colors.red);
  }
}

Future<void> _scheduleNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    icon: '@drawable/ic_lancher',
    importance: Importance.max,
    priority: Priority.high,
  );
  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await FlutterLocalNotificationsPlugin().show(
    10,
    'New Notification',
    'Hello, World!',
    platformChannelSpecifics,
    payload: 'item x',
  );
}
