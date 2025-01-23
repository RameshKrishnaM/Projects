import 'package:flutter/material.dart';
import 'package:medapp/firstpage.dart';
import 'package:medapp/loginpage.dart';

class RouteGenarator {
  String screen1 = '/firstPage';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );

      case '/firstPage':
        if (args is Map<dynamic, dynamic>) {
          return MaterialPageRoute(
            builder: (context) => FirstPage(
              username: args['User Id']!,
              role: args['role']!,
            ),
          );
        }
        return errorRoute();
      case '/Logout':
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );

      default:
        return errorRoute();
    }
  }
}

Route<dynamic> errorRoute() {
  return MaterialPageRoute(
    builder: (context) {
      return const Scaffold(
        body: Center(
          child: Text('Error: Page not found'),
        ),
      );
    },
  );
}
