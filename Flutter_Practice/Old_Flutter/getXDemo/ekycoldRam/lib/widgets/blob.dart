import 'package:flutter/material.dart';
import 'package:projectdemo2/widgets/mycolor.dart';

class MyBlob extends StatefulWidget {
  const MyBlob({Key? key}) : super(key: key);

  @override
  State<MyBlob> createState() => _MyBlobState();
}

class _MyBlobState extends State<MyBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(begin: 0.5, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 80,
            child: Transform.rotate(
              angle: 47,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animation.value * 0.1),
                    child: child,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: highlightcolor),
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.elliptical(450, 450),
                      topEnd: Radius.elliptical(150, 200),
                      bottomStart: Radius.elliptical(220, 150),
                      bottomEnd: Radius.elliptical(320, 250),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 35,
            left: 87,
            child: Transform.rotate(
              angle: 47,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animation.value * 0.1),
                    child: child,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  height: 165,
                  width: 165,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        blobcolor1,
                        blobcolor2,
                        blobcolor3,
                      ],
                    ),
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.elliptical(450, 450),
                      topEnd: Radius.elliptical(150, 200),
                      bottomStart: Radius.elliptical(220, 150),
                      bottomEnd: Radius.elliptical(320, 250),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 30,
            child: Image.asset(
              'images/IPV-removebg-preview-removebg-preview.png',
              height: 255,
              width: 255,
            ),
          )
        ],
      ),
    );
  }
}
