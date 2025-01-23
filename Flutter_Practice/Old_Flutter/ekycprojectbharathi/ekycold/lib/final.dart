import 'package:flutter/material.dart';

class FinalPage extends StatefulWidget{
  const FinalPage({super.key});

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
        body:Container( 
           child:Stack(children: <Widget>[ 
                Opacity( 
                  opacity: 0.4, 
                  child: ClipPath( 
                      clipper:WaveClipper(),
                        child:Container( 
                            color:Colors.blue,
                            height:530,
                        ),
                     ),
                ),

                ClipPath(  
                    clipper:WaveClipper(),
                      child:Container( 
                          padding: EdgeInsets.only(bottom: 50),
                          color:Colors.blue,
                          height:460,
                          alignment: Alignment.center,
                          
                     ),
                     
                ),
           ],)
        )
    );
  }
}

//Costom CLipper class with Path
class WaveClipper extends CustomClipper<Path>{
//   @override
//   Path getClip(Size size) {
//     double w = size.width;
//     double h = size.height;
//     Path path = Path();
//     // remove Move step
//     path.lineTo(0, h);
//     path.lineTo(w * 2/ 7, h);
//     path.lineTo(w, 0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }

//   @override
//   Path getClip(Size size) {
//     double w = size.width;
//     double h = size.height;

//     Path path = Path();
//     path.moveTo(w * 1 / 9, 0);

//     path.lineTo(0, h);
//     path.lineTo(w * 8 / 9, h);
//     path.lineTo(w, 0);

//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }

//  @override
//   Path getClip(Size size) {
//     double w = size.width;
//     double h = size.height;
//     Path path = Path();
//     path.moveTo(w * 3/ 7, 0);
//     path.lineTo(0, h);
//     path.lineTo(w , h); // edited
//     path.lineTo(w, 0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }


 @override
  getClip(Size size) {
    double height = size.height;
    double width = size.width;

    var p = Path();
    p.lineTo(0, 0);
    p.cubicTo(width * 1 / 2, 0, width * 2 / 4, height, width, height);
    p.lineTo(width, 0);
    p.close();

    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}

//  @override
//   getClip(Size size) {
//     double height = size.height;
//     double width = size.width;
//     double curveHeight = size.height / 2;

//     var p = Path();
//     p.lineTo(0, height - curveHeight);
//     p.quadraticBezierTo(width / 2, height, width, height - curveHeight);
//     p.lineTo(width, 0);
//     p.close();

//     return p;
//   }

//   @override
//   bool shouldReclip(CustomClipper oldClipper) => true;
// }





//  @override

//   Path getClip(Size size) {

//     var path = new Path();

//     path.lineTo(0.0, size.height - 40);

//     path.quadraticBezierTo(

//         size.width / 4, size.height - 80, size.width / 2, size.height - 40);

//     path.quadraticBezierTo(size.width - (size.width / 4), size.height,

//         size.width, size.height - 40);

//     path.lineTo(size.width, 0.0);

//     path.close();

//     return path;

//   }

//   @override

//   bool shouldReclip(CustomClipper<Path> oldClipper) {

//     return false;

//   }

// }