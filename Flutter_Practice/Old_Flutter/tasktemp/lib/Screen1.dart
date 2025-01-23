import 'package:flutter/material.dart';
import 'route.dart' as route;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showbottomsheet();
    });
  }

  void showbottomsheet() {
    showModalBottomSheet(
        barrierColor: Colors.transparent,
        transitionAnimationController: AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        ),
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            // width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              children: [
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Find your ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 30.0,
                    color: const Color(0xFF444547).withOpacity(0.9),
                  ),
                ),
                Text(
                  'Dream House',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 30.0,
                    color: const Color(0xFF444547).withOpacity(0.9),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: AutoSizeText(
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    'We always ready to provide you the best rental house within effordable price',
                    style: GoogleFonts.lobster(
                      textStyle: const TextStyle(
                        height: 1.5,
                        color: Color(0xFF848484),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.all(15.0)),
                    backgroundColor: MaterialStatePropertyAll(
                      Color(0xFFEAEDF9),
                    ),
                    shape: MaterialStatePropertyAll(
                      StarBorder.polygon(sides: 4.0, pointRounding: 0.5),
                    ),
                  ),
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => const Screen2(),
                    //     ));
                    Navigator.pushNamed(context, route.screen2);
                  },
                  child: const Icon(
                    Icons.arrow_right_alt_rounded,
                    color: Color(0xFF4974FF),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text('skip'),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/house.jpg'),
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ),
    );
  }
}
