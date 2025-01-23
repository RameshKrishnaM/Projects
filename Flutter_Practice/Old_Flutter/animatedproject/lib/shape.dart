import 'dart:math';

import 'package:flutter/material.dart';

class ShapeAnimation extends StatefulWidget {
  const ShapeAnimation({Key? key}) : super(key: key);

  @override
  State<ShapeAnimation> createState() => _ShapeAnimationState();
}

class _ShapeAnimationState extends State<ShapeAnimation> {
  Random random = Random();
  // bool isclick = false;
  double boxHeight = 100;
  double boxWidth = 100;
  // BoxShape boxShapes = BoxShape.rectangle;
  Gradient boxColor = LinearGradient(
    colors: [
      Color.fromRGBO(255, 0, 0, 1.0),
      Color.fromRGBO(0, 255, 0, 1.0),
      Color.fromRGBO(0, 0, 255, 1.0),
    ],
  );
  BorderRadius borderRadius = BorderRadius.circular(0.0);
  void getRandomRadius() {
    setState(() {
      borderRadius = BorderRadius.circular(random.nextInt(60).toDouble());
    });
  }

  void chageBoxSize() {
    setState(() {
      boxWidth = random.nextInt(350).toDouble();
      boxHeight = random.nextInt(350).toDouble();
    });
  }

  void changeBoxColor() {
    setState(() {
      boxColor = LinearGradient(
        tileMode: TileMode.repeated,
        colors: [
          Color.fromRGBO(
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
            1.0,
          ),
          Color.fromRGBO(
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
            1.0,
          ),
          Color.fromRGBO(
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
            1.0,
          ),
        ],
      );
    });
  }

  // void shapeChange() {
  //   setState(() {
  //     boxShapes = isclick ? BoxShape.circle : BoxShape.rectangle;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 1000),
                height: boxHeight,
                width: boxWidth,
                decoration: BoxDecoration(
                  // color: Colors.teal,
                  // borderRadius: BorderRadius.only(
                  //   topLeft: Radius.circular(50),
                  //   bottomLeft: Radius.circular(80),
                  //   topRight: Radius.circular(80.0),
                  //   bottomRight: Radius.circular(50),
                  // ),
                  borderRadius: borderRadius,
                  gradient: boxColor,
                  // shape: boxShapes,
                ),
              ),
              ClipOval(
                child: AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 1000),
                  height: boxHeight,
                  width: boxWidth,
                  decoration: BoxDecoration(
                    // color: Colors.teal,
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(30),
                    //   bottomLeft: Radius.circular(90),
                    //   topRight: Radius.circular(90.0),
                    //   bottomRight: Radius.circular(30),
                    // ),
                    borderRadius: borderRadius,
                    gradient: boxColor,
                    // shape: boxShapes,
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                changeBoxColor();
              },
              icon: Icon(Icons.color_lens_outlined),
            ),
            // IconButton(
            //   onPressed: () {
            //     isclick = !isclick;
            //     shapeChange();
            //   },
            //   icon: Icon(Icons.shape_line),
            // ),
            IconButton(
              onPressed: () {
                getRandomRadius();
              },
              icon: Icon(Icons.interests),
            ),
            IconButton(
              onPressed: () {
                chageBoxSize();
              },
              icon: Icon(Icons.aspect_ratio),
            ),
          ],
        ),
      ),
    );
  }
}
