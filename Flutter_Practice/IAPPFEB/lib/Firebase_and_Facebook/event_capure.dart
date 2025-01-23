import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackBar.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../Route/route.dart';
import '../provider/provider.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FacebookAppEvents facebookevents = FacebookAppEvents();
insertRouteNameInFireBase({required context, required newRouteName}) async {
  String mobileNo = Provider.of<Postmap>(context, listen: false).mobileNo;

  analytics.setAnalyticsCollectionEnabled(true);

  // String? token = await FirebaseMessaging.instance.getToken();
  String collectionName = 'user';
  var firebaseFirestoreInstance = FirebaseFirestore.instance;

  try {
    var collectionDetails =
        await firebaseFirestoreInstance.collection(collectionName).get();
    int index =
        collectionDetails.docs.indexWhere((element) => element.id == mobileNo);
    if (index == -1) {
      throw Exception("not present");
    } else {
      Map<String, dynamic> data = collectionDetails.docs[index].data();
      // String oldRouteName = data["stage"];
      int oldRouteDetails = routeNames.entries
          .toList()
          .indexWhere((element) => element.value == data["stage"]);
      int newRouteDetails = routeNames.entries
          .toList()
          .indexWhere((element) => element.value == newRouteName);
      if (oldRouteDetails < newRouteDetails || oldRouteDetails == -1) {
        newRouteName = newRouteName == "Address"
            ? "AddressScreen"
            : newRouteName == "Main"
                ? "login"
                : newRouteName;
        String oldRoute = data["stage"];
        // print("new route $newRouteName");
        data["stage"] = newRouteName;
        firebaseFirestoreInstance
            .collection(collectionName)
            .doc(mobileNo)
            .update(data);
        subScribeTopic(newRouteName);
        unSubScribeTopic(oldRoute);
        insertEvents(context, newRouteName);
      }
    }
    // else {
    //   Map<String, dynamic> oldDetails = value.docs[index].data();
    //   oldDetails["phone"] = "9876500104";
    //   firebaseFirestoreInstance.doc(widget.email).update(oldDetails);
    //
  } catch (e) {
    String? token = await FirebaseMessaging.instance.getToken();
    firebaseFirestoreInstance.collection(collectionName).doc(mobileNo).set({
      "name": "",
      "Date": DateTime.now().toString().substring(0, 10),
      "phone": mobileNo,
      "email": Provider.of<Postmap>(context, listen: false).email,
      "token": token,
      "stage": newRouteName
    });
    subScribeTopic(newRouteName);
    insertEvents(context, newRouteName);
  }
}

insertEvents(BuildContext context, String newRouteName) async {
  // print(
  //     "${Provider.of<Postmap>(context, listen: false).mobileNo} ${CustomHttpClient.testMobileNo}");
  if (Provider.of<Postmap>(context, listen: false).mobileNo ==
      CustomHttpClient.testMobileNo) {
    // print("event not capture");
    return;
  }
  // print("event capture");
  try {
    await analytics.setAnalyticsCollectionEnabled(true);
    await analytics.logEvent(
        name: newRouteName,
        parameters: {"device": "Android"},
        callOptions: AnalyticsCallOptions(global: true));
    await facebookevents.logEvent(
      name: newRouteName,
      // parameters: {"mobileNo": mobileNumber},
    );
    // showSnackbar(context, "event is triggered", Colors.green);
  } catch (e) {
    // showSnackbar(context, "event Error ${e.toString()}", Colors.red);
  }
}

subScribeTopic(String newRouteName) async {
  try {
    await FirebaseMessaging.instance.subscribeToTopic(newRouteName);
    print("new subscribe topic $newRouteName");
  } catch (e) {}
}

unSubScribeTopic(String oldRouteName) async {
  try {
    await FirebaseMessaging.instance.unsubscribeFromTopic(oldRouteName);
    print("unsubscribe topic $oldRouteName");
  } catch (e) {}
}
