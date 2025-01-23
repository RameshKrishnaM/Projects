import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekyc/Cookies/cookies.dart';
// import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../Route/route.dart';
import '../provider/provider.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
// FacebookAppEvents facebookevents = FacebookAppEvents();
insertRouteNameInFireBase({required context, required newRouteName}) async {
  String mobileNo = Provider.of<ProviderClass>(context, listen: false).mobileNo;

  analytics.setAnalyticsCollectionEnabled(true);

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
  } catch (e) {
    String? token = await FirebaseMessaging.instance.getToken();
    firebaseFirestoreInstance.collection(collectionName).doc(mobileNo).set({
      "name": "",
      "Date": DateTime.now().toString().substring(0, 10),
      "phone": mobileNo,
      "email": Provider.of<ProviderClass>(context, listen: false).email,
      "token": token,
      "stage": newRouteName
    });
    subScribeTopic(newRouteName);
    insertEvents(context, newRouteName);
  }
}

insertEvents(BuildContext context, String newRouteName) async {
  if (Provider.of<ProviderClass>(context, listen: false).mobileNo ==
      CustomHttpClient.testMobileNo) {
    return;
  }
  try {
    await analytics.setAnalyticsCollectionEnabled(true);
    await analytics.logEvent(
        name: newRouteName,
        parameters: {"device": "Android"},
        callOptions: AnalyticsCallOptions(global: true));
    // await facebookevents.logEvent(
    //   name: newRouteName,
    // );
  } catch (e) {}
}

subScribeTopic(String newRouteName) async {
  try {
    await FirebaseMessaging.instance.subscribeToTopic(newRouteName);
  } catch (e) {}
}

unSubScribeTopic(String oldRouteName) async {
  try {
    await FirebaseMessaging.instance.unsubscribeFromTopic(oldRouteName);
  } catch (e) {}
}
