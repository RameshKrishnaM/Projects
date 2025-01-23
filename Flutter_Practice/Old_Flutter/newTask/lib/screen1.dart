import 'dart:async';

import 'package:flutter/material.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> images = [
    'assets/images/601840.jpg',
    'assets/images/601909.jpg',
    'assets/images/614664.jpg',
    'assets/images/807772.jpg',
    'assets/images/imageedit_1_8992576734.jpg'
  ];
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutSine,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 200,
        child: PageView.builder(
          controller: _controller,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Image.asset(
              images[index],
              fit: BoxFit.cover,
            );
          },
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
        ),
      ),
    );
  }
}
