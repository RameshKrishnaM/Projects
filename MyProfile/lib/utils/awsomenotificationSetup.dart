// import 'dart:isolate';
// import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:novo/utils/colors.dart';
import 'package:open_filex/open_filex.dart';

class AwesomeNotificationController {
  static ReceivedAction? initialAction;

  /// *********************************************
  /// INITIALIZATIONS
  /// *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      null, //'resource://drawable/res_app_icon',//
      [
        NotificationChannel(
            channelKey: 'alerts',
            channelName: 'Alerts',
            channelDescription: 'Notification tests as alerts',
            playSound: true,
            onlyAlertOnce: true,
            groupAlertBehavior: GroupAlertBehavior.Children,
            importance: NotificationImportance.High,
            defaultPrivacy: NotificationPrivacy.Private,
            defaultColor: appPrimeColor,
            ledColor: appPrimeColor)
      ],
    );

// Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

//

  /// *********************************************
  /// NOTIFICATION EVENTS LISTENER
  /// *********************************************
  /// Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  /// *********************************************
  /// NOTIFICATION EVENTS
  /// *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print("key ${receivedAction.groupKey}");
    print(receivedAction.groupKey == "progress");
    print(receivedAction.groupKey == "file");
    if (receivedAction.groupKey == "progress") return;
    if ((receivedAction.payload?['filePath'] ?? "").isNotEmpty) {
      print("file path ${receivedAction.payload?['filePath'] ?? ""}");
      OpenResult res =
          await OpenFilex.open(receivedAction.payload?['filePath'] ?? "");
      print("message ${res.message}");
      print("type ${res.type}");
      // print("message ${res.message}");
// SystemNavigator.pop();
    }
  }
}
