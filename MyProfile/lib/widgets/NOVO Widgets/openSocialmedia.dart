import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void openApp(BuildContext context, String appName, String appUrl,
    String playStoreUrl) async {
  try {
    if (await launchUrl(Uri.parse(appUrl))) {
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('App Not Installed'),
            content: Text('The $appName app is not installed on your device.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Launch Play Store URL
                  launchUrl(Uri.parse(playStoreUrl));
                },
                child: const Text('Install from Play Store'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Not Installed'),
          content: Text('The $appName app is not installed on your device.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Launch Play Store URL
                launchUrl(Uri.parse(playStoreUrl));
              },
              child: const Text('Install from Play Store'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
