import 'package:flutter/material.dart';

class CustomUpload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            width: 300, // Adjust the width as needed
            height: 400, // Adjust the height as needed
            color: Color(0xFFA259FF), // Purple background color
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate Us",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.greenAccent, size: 30),
                      Icon(Icons.star, color: Colors.greenAccent, size: 30),
                      Icon(Icons.star, color: Colors.greenAccent, size: 30),
                      Icon(Icons.star, color: Colors.grey, size: 30),
                      Icon(Icons.star, color: Colors.grey, size: 30),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Leave a comment (optional)",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: "Enter your message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF64FFDA), // Light green color
                      ),
                      child: Text("Send"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cutoutWidth = 70;
    double cutoutHeight = 30;

    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - cutoutHeight);
    path.lineTo(size.width / 2 - cutoutWidth / 2, size.height - cutoutHeight);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 + cutoutWidth / 2, size.height - cutoutHeight);
    path.lineTo(size.width, size.height - cutoutHeight);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
