import 'package:flutter/material.dart';
import 'package:project2/backgroundAnimatedContainer.dart';
import 'package:project2/personalDetails.dart';
import 'package:project2/style.dart';

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Opacity(
          opacity: 0.4,
          child: ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: AppColors.primary,
              height: double.infinity,
            ),
          ),
        ),
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            padding: EdgeInsets.only(bottom: 50),
            color: AppColors.light,
            height: 560,
            alignment: Alignment.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 2, 30),
          child: ListView(
            children: [
              SizedBox(
                height: size.height * 0.4,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    BackgroundAnimatedContainer(
                      linerColors: [
                        AppColors.darkSecondary,
                        AppColors.darkTernary,
                        AppColors.primary,
                        AppColors.secondary
                      ],
                    ),
                    Image.asset(
                      // 'assets/images/Screenshot_from_2023-12-20_17-18-05-removebg-preview.png',
                      'assets/images/Screenshot_from_2023-12-09_12-34-22-removebg-preview.png',
                      height: 230,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      AppColors.darkPrimary,
                      AppColors.primary,
                      AppColors.accent
                    ],
                  ).createShader(bounds);
                },
                child: Text('Details',
                    style: AppFont.heading(
                            textColor: AppColors.light,
                            fontWeight: FontWeight.bold)
                        .primary),
              ),
              const SizedBox(height: 10),
              const PersonalDetails(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     double w = size.width;
//     double h = size.height;
//     Path path = Path();
//     path.lineTo(h * 4 / 15, w * 4 / 14);
//     path.lineTo(w, 0);
//     path.lineTo(0, h);
//     path.lineTo(w * 3, 0);
//     path.lineTo(0, h * 4);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
