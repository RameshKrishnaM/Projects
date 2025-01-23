// import 'package:circular_menu/circular_menu.dart';
// import 'package:fab_circular_menu/fab_circular_menu.dart';
// import 'package:flutter/material.dart';

// class MyCustomClipPath extends StatefulWidget {
//   const MyCustomClipPath({super.key});

//   @override
//   State<MyCustomClipPath> createState() => _MyCustomClipPathState();
// }

// class _MyCustomClipPathState extends State<MyCustomClipPath> {
//   final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Scaffold(
//         body: ClipPath(
//           clipper: CustomShape(),
//           child: Container(
//             height: 150,
//             color: Colors.teal,
//           ),
//         ),
//         // floatingActionButton: Builder(builder: (context) {
//         //   return FabCircularMenu(
//         //     key: fabKey,
//         //     animationCurve: Curves.bounceIn,
//         //     animationDuration: Duration(milliseconds: 800),
//         //     ringColor: Colors.amber,
//         //     ringDiameter: 5,
//         //     ringWidth: 5,
//         //     children: [
//         //       Icon(Icons.home),
//         //       Icon(Icons.chat),
//         //       Icon(Icons.settings),
//         //       Icon(Icons.camera_alt_rounded),
//         //     ],
//         //   );
//         // }),
//         floatingActionButton: CircularMenu(
//           alignment: Alignment.bottomRight,
//           items: [
//             CircularMenuItem(
//               onTap: () {},
//               icon: Icons.home,
//             ),
//             CircularMenuItem(
//               onTap: () {},
//               icon: Icons.chat,
//             ),
//             CircularMenuItem(
//               onTap: () {},
//               icon: Icons.settings,
//             ),
//             CircularMenuItem(
//               onTap: () {},
//               icon: Icons.camera_alt_rounded,
//             ),
//           ],
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       ),
//     ));
//   }
// }

// class CustomShape extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();

//     double h = size.height;
//     double w = size.width;

//     path.lineTo(0, h);
//     // path.lineTo(w, h);
//     // path.moveTo(w * 10, h);
//     path.quadraticBezierTo(w * 0.5 / 2, h * 0.5, w, h);

//     path.lineTo(w, 0);

//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }

//--------------------------------------------------------------------

// import 'dart:async';

// import 'package:flutter/material.dart';

// class MusicPlayer extends StatefulWidget {
//   const MusicPlayer({super.key});

//   @override
//   State<MusicPlayer> createState() => _MusicPlayerState();
// }

// class _MusicPlayerState extends State<MusicPlayer> {
//   Timer? countDownTimer;
//   Duration duration = const Duration(seconds: 0);
//   bool musicON = false;

//   void startTimer() {
//     countDownTimer = Timer.periodic(
//         const Duration(
//           milliseconds: 1000,
//         ), (timer) {
//       const increaseTimer = 10;
//       setState(() {
//         final seconds = duration.inSeconds + increaseTimer;
//         if (seconds >= 210) {
//           countDownTimer!.cancel();
//           duration = const Duration(seconds: 0);
//           musicON = false;
//         } else {
//           duration = Duration(seconds: seconds);
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return SafeArea(
//         child: Scaffold(
//       backgroundColor: Colors.white,
//       body: SizedBox(
//         height: size.height,
//         width: size.width,
//         child: Stack(
//           children: [
//             Container(
//               height: size.height * 0.4,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.black, width: 3.0),
//                 color: const Color.fromRGBO(248, 32, 43, 1),
//                 borderRadius: const BorderRadius.only(
//                   bottomRight: Radius.circular(100.0),
//                 ),
//               ),
//             ),
//             Container(
//               height: size.height * 0.33,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.black, width: 3.0),
//                 color: Colors.teal,
//                 borderRadius: const BorderRadius.only(
//                   bottomRight: Radius.circular(100.0),
//                 ),
//               ),
//             ),
//             Container(
//               height: size.height * 0.26,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.black, width: 3.0),
//                 color: Colors.amber,
//                 borderRadius: const BorderRadius.only(
//                   bottomRight: Radius.circular(100.0),
//                 ),
//               ),
//               padding: const EdgeInsets.all(15.0),
//               alignment: Alignment.topCenter,
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Icon(
//                     Icons.arrow_back,
//                   ),
//                   Icon(
//                     Icons.library_music_rounded,
//                   )
//                 ],
//               ),
//             ),
//             Positioned(
//               top: size.height * 0.1,
//               right: size.width * 0.15,
//               child: Container(
//                 height: size.height * 0.4,
//                 width: size.width * 0.7,
//                 decoration: BoxDecoration(
//                   border: Border.all(width: 3.0),
//                   shape: BoxShape.circle,
//                   image: const DecorationImage(
//                       image: AssetImage('images/unnamed.webp'),
//                       fit: BoxFit.cover),
//                 ),
//               ),
//               // child: CircleAvatar(
//               //   backgroundImage: AssetImage('images/unnamed.webp'),
//               //   radius: 130,
//               // ),
//             ),
//             Positioned(
//               top: size.height * 0.48,
//               child: Center(
//                 child: Container(
//                   height: size.height * 0.4,
//                   width: size.width,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "We Don't Talk Anymore",
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 4,
//                       ),
//                       const Text(
//                         "Charlie Puth/Selena Gomez",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SliderTheme(
//                         data: SliderThemeData(
//                           trackHeight: 5,
//                           overlayShape: SliderComponentShape.noOverlay,
//                           thumbShape: const RoundSliderThumbShape(
//                             enabledThumbRadius: 14,
//                           ),
//                         ),
//                         child: Slider(
//                           min: 0,
//                           max: 200,
//                           value: duration.inSeconds.toDouble(),
//                           inactiveColor: Colors.grey.shade300,
//                           activeColor: Colors.black,
//                           thumbColor: Colors.yellow,
//                           onChanged: (value) {
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             duration.toString().substring(2, 7),
//                           ),
//                           const Text(
//                             '03:20',
//                           ),
//                         ],
//                       ),
//                       Flexible(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             const Icon(
//                               Icons.fast_rewind,
//                               size: 40,
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 startTimer();
//                                 // change icon
//                                 setState(() {
//                                   musicON = !musicON;
//                                 });
//                               },
//                               child: CircleAvatar(
//                                 radius: 40,
//                                 backgroundColor: Colors.black,
//                                 child: musicON
//                                     ? const Icon(
//                                         Icons.pause_outlined,
//                                         color: Colors.white,
//                                         size: 30,
//                                       )
//                                     : const Icon(
//                                         Icons.play_arrow,
//                                         color: Colors.white,
//                                         size: 30,
//                                       ),
//                               ),
//                             ),
//                             const Icon(
//                               Icons.fast_forward,
//                               size: 40,
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               child: Container(
//                 height: size.height * 0.15,
//                 width: size.width,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(width: 5, color: Colors.black),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(60),
//                       topRight: Radius.circular(60),
//                     )),
//                 padding: const EdgeInsets.fromLTRB(30, 18, 30, 10),
//                 child: Row(
//                   children: [
//                     Container(
//                       height: size.height * 0.1,
//                       width: size.width * 0.2,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         image: const DecorationImage(
//                             image: AssetImage('images/alan-walker.jpeg'),
//                             fit: BoxFit.cover),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Faded',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 6,
//                         ),
//                         Text(
//                           'Alan Walker',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }



/*

Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isStretched = !isStretched;
                            });
                          },
                          child: Container(
                            height: 30.0,
                            width: 170.0,
                            decoration: BoxDecoration(
                              border: isStretched
                                  ? const Border.symmetric(
                                      horizontal: BorderSide.none)
                                  : Border.all(
                                      color: Colors.grey.shade700,
                                      width: 1.0,
                                    ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    isStretched ? '' : selectedItem,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: selectedItem == 'Options'
                                          ? Colors.grey.shade700
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Icon(isStretched
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            'View Scheme Details',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isStretched)
                      SingleChildScrollView(
                        child: Container(
                          width: 170.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade700,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Scrollbar(
                            child: ListView(
                              children: options.map((option) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedItem = option;
                                      isStretched = false;
                                    });
                                  },
                                  child: Container(
                                    height: 30.0,
                                    padding: const EdgeInsets.only(left: 10.0),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

 */