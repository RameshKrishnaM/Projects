import 'package:flutter/material.dart';

class BookTicket extends StatefulWidget {
  const BookTicket({super.key});

  @override
  State<BookTicket> createState() => _BookTicketState();
}

class _BookTicketState extends State<BookTicket> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Scaffold(
          body: Container(
            color: Colors.teal,
            child: Center(
              child: ClipPath(
                clipper: TicketClip(),
                child: Container(
                  height: size.height * 0.7,
                  width: size.width * 0.8,
                  color: Colors.white,
                  child: Column(
                    children: [
                      ClipPath(
                        clipper: ClipDesign(),
                        child: Container(
                          height: size.height * 0.46,
                          color: Colors.blue,
                          child: Icon(Icons.menu),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClipDesign extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double h = size.height;
    double w = size.width;
    path.moveTo(12, 12);
    path.lineTo(12, h - 60);
    path.lineTo(40, h - 5);
    path.lineTo(w, h - 5);
    path.lineTo(w - 40, h - 5);
    path.lineTo(w - 12, h - 60);
    path.lineTo(w - 12, 12);
    path.lineTo(w / 1.5, 12);
    // path.quadraticBezierTo(w / 2, 60, w / 3.2, 12);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class TicketClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    double h = size.height;
    double w = size.width;
    path.lineTo(0, h - 220);
    path.lineTo(32, h - 160);
    path.lineTo(0, h - 110);
    path.lineTo(0, h);
    path.lineTo(w / 3, h);
    path.quadraticBezierTo(w / 2, h - 58, w / 1.5, h);
    path.lineTo(w, h);
    path.lineTo(w, h - 110);
    path.lineTo(w - 32, h - 160);
    path.lineTo(w, h - 220);
    path.lineTo(w, 0);
    path.lineTo(w / 1.5, 0);
    path.quadraticBezierTo(w / 2, 50, w / 3, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
