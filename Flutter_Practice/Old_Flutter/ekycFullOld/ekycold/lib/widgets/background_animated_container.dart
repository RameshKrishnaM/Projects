import 'package:ekycold/util/colors.dart';
import 'package:flutter/material.dart';

class BackgroundAnimatedContainer extends StatefulWidget {
  final String image;
  const BackgroundAnimatedContainer({super.key, required this.image});

  @override
  State<BackgroundAnimatedContainer> createState() =>
      _BackgroundAnimatedContainerState();
}

class _BackgroundAnimatedContainerState
    extends State<BackgroundAnimatedContainer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.65, end: .8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: Transform.rotate(
              angle: 47,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return AnimatedContainer(
                      padding: const EdgeInsets.all(15.0),
                      duration: const Duration(seconds: 5),
                      height: 400 * _animation.value,
                      width: 400 * _animation.value,
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.0, color: Colors.grey.withOpacity(0.30)),
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.elliptical(450, 450),
                          topEnd: Radius.elliptical(150, 200),
                          bottomStart: Radius.elliptical(220, 150),
                          bottomEnd: Radius.elliptical(320, 250),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          // color: Color(0xFF0965DA).withOpacity(0.70),
                          // gradient: LinearGradient(
                          //   colors: [
                          //     Colors.blueGrey,
                          //     Colors.blue.shade700,
                          //     Colors.blue.shade400,
                          //     Colors.blue.shade300
                          //   ],
                          //   // stops: const [0.1, 0.4, 0.8, 1],
                          // ),
                          borderRadius: const BorderRadiusDirectional.only(
                            topStart: Radius.elliptical(450, 450),
                            topEnd: Radius.elliptical(150, 200),
                            bottomStart: Radius.elliptical(220, 150),
                            bottomEnd: Radius.elliptical(320, 250),
                          ),
                        ),
                      ));
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30.0),
            // alignment: Alignment.bottomCenter,
            child: Image.asset(
              "assets/images/${widget.image}",
              // 'assets/images/Screenshot_from_2023-12-09_12-34-22-removebg-preview.png',
              width: 290,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
