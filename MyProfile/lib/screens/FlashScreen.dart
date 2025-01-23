// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/cookies/cookies.dart';
import 'package:novo/screens/loginwithpass.dart';
import 'package:novo/widgets/NOVO%20Widgets/snackbar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../Roating/route.dart' as route;

class FlashSCreenPage extends StatefulWidget {
  const FlashSCreenPage({super.key});
  @override
  State<FlashSCreenPage> createState() => _FlashSCreenPageState();
}

class _FlashSCreenPageState extends State<FlashSCreenPage> {
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    // animation();
    cookieverify();
  }

  // animation() async {
  //   await Future.delayed(const Duration(milliseconds: 3500), () {
  //     Navigator.pushReplacement(
  //       context,
  //       PageTransition(
  //         child: const LoginPage(),
  //         type: PageTransitionType.fade,
  //       ),
  //     );
  //   });
  // }

  Future<void> cookieverify() async {
    await Future.delayed(const Duration(milliseconds: 3500), () async {
      await Provider.of<NavigationProvider>(context, listen: false).getCookie();
      bool cookieValid = await verifyCookies(context);

      if (cookieValid) {
        Navigator.pushNamed(context, route.novoPage, arguments: 1);
      } else {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: const LoginPage(),
            type: PageTransitionType.fade,
          ),
        );

        // _connectivity.onConnectivityChanged
        //     .listen((ConnectivityResult result) async {
        //   if (!(result == ConnectivityResult.mobile ||
        //       result == ConnectivityResult.wifi)) {
        //     WidgetsBinding.instance.addPostFrameCallback((_) {
        //       showSnackbar(context, "No internet", Colors.red);
        //     });
        //   }
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/Novo_Animation .gif",
            ),
          )
        ],
      ),
    );
  }
}
