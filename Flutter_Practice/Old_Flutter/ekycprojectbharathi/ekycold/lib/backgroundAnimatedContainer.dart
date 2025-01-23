// import 'package:flutter/material.dart';

// class BackgroundAnimatedContainer extends StatefulWidget {
//   final List<Color> linerColors;
//   const BackgroundAnimatedContainer({super.key, required this.linerColors});

//   @override
//   State<BackgroundAnimatedContainer> createState() =>
//       _BackgroundAnimatedContainerState();
// }

// class _BackgroundAnimatedContainerState
//     extends State<BackgroundAnimatedContainer> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       duration: Duration(seconds: 2),
//       vsync: this,
//     );

//     _animation = Tween<double>(begin: 0.5, end: .7).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _controller.repeat(reverse: true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return
//        Center(
//          child: Transform.rotate(
//           angle: 47,
//           child: AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return AnimatedContainer(
//                 duration: Duration(seconds: 5),
//                 height: 400 * _animation.value,
//                 width: 400 * _animation.value,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     style: BorderStyle.solid,
//                     width: 1,
//                     color: Colors.black
//                   ),
//                   gradient: LinearGradient(
//                     colors: widget.linerColors,
//                   ),
//                   borderRadius: const BorderRadiusDirectional.only(
//                     topStart: Radius.elliptical(450, 450),
//                     topEnd: Radius.elliptical(150, 200),
//                     bottomStart: Radius.elliptical(220, 150),
//                     bottomEnd: Radius.elliptical(320, 250),
//                   ),
//                 ),
//               );
//             },
//           ),

//            ),
//        );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

import 'package:ekycold/style.dart';
import 'package:flutter/material.dart';

class BackgroundAnimatedContainer extends StatefulWidget {
  final List<Color> linerColors;

  const BackgroundAnimatedContainer({Key? key, required this.linerColors})
      : super(key: key);

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
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: .7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Transform.rotate(
            angle: 47,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: Duration(seconds: 5),
                  height: 405 * _animation.value,
                  width: 405 * _animation.value,
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    border: Border.all(
                      style: BorderStyle.solid,
                      width: 2,
                      color: AppColors.darkSecondary,
                    ),
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.elliptical(450, 450),
                      topEnd: Radius.elliptical(150, 200),
                      bottomStart: Radius.elliptical(220, 150),
                      bottomEnd: Radius.elliptical(320, 250),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Center(
          child: Transform.rotate(
            angle: 47,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: Duration(seconds: 5),
                  height: 380 * _animation.value,
                  width: 380 * _animation.value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.linerColors,
                    ),
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.elliptical(450, 450),
                      topEnd: Radius.elliptical(150, 200),
                      bottomStart: Radius.elliptical(220, 150),
                      bottomEnd: Radius.elliptical(320, 250),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
