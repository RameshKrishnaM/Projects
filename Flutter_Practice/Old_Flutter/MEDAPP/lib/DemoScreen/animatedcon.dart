import 'package:flutter/material.dart';

class CustomContainer extends StatefulWidget {
  const CustomContainer({super.key});

  @override
  State<CustomContainer> createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 100,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 1000),
                height: 250,
                width: 230,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topRight:
                        Radius.elliptical(280, 350), // Adjust these values
                    bottomRight:
                        Radius.elliptical(300, 620), // to better match the blob
                    topLeft: Radius.elliptical(690, 500), // curvature
                    bottomLeft: Radius.elliptical(690, 560),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
