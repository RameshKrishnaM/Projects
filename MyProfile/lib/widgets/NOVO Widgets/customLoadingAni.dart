// ignore_for_file: file_names

import 'package:flutter/material.dart';

class LoadingProgress extends StatefulWidget {
  const LoadingProgress({super.key});

  @override
  State<LoadingProgress> createState() => _LoadingProgressState();
}

class _LoadingProgressState extends State<LoadingProgress> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 53,
        height: 53,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.blue.shade100,
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 0))
        ], borderRadius: BorderRadius.circular(50), color: Colors.white),
        child: Center(
            child: Container(
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Image.asset(
            "assets/NOVO loader.gif",
          ),
        )),
      ),
    );
  }
}





/*
import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';

class loadingProgress extends StatefulWidget {
  const loadingProgress({super.key});

  @override
  State<loadingProgress> createState() => _loadingProgressState();
}

class _loadingProgressState extends State<loadingProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    super.initState();
    _animation = Tween<double>(begin: 0.0, end: 6).animate(_controller);
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorLight
            : titleTextColorDark;
    return Center(
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateZ(_animation.value),
              child: Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.shade100,
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 0))
                    ],
                    borderRadius: BorderRadius.circular(50),
                    color:
                        // themeBasedColor
                        Colors.white),
                child: Center(
                    child: Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    // border: Border.all(
                    //     color: Colors.blue,
                    //     width: 1.5,
                    //     strokeAlign: BorderSide.strokeAlignCenter,
                    //     style: BorderStyle.solid)
                  ),
                  child: Image.asset(
                    // "assets/Novo_Animation .gif",
                    // "assets/Novo_app_Logo.png"
                    "assets/NOVO loader.gif", width: 40,
                  ),
                )),
              ),
            );
          }),
    );
  }
}



*/