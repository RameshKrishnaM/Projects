import 'package:flutter/material.dart';

class MenuIconAnimator extends StatefulWidget {
  @override
  _MenuIconAnimatorState createState() => _MenuIconAnimatorState();
}

class _MenuIconAnimatorState extends State<MenuIconAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animated Menu Icon'),
      ),
      body: Center(
        child: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController.view,
          ),
          onPressed: () {
            if (_animationController.status == AnimationStatus.completed) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
          },
        ),
      ),
    );
  }
}
