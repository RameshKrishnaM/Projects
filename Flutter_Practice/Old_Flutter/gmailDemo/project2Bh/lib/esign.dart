import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:project2/customButton.dart';
import 'package:project2/pageSwap.dart';
import 'package:project2/style.dart';
import 'package:provider/provider.dart';

class Esign extends StatefulWidget {
  const Esign({Key? key}) : super(key: key);

  @override
  State<Esign> createState() => _EsignState();
}

class _EsignState extends State<Esign> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageSwap>(
      builder: (context, value, child) => Scaffold(
        body: Stack(
          children: [
            CarouselSlider.builder(
              slideTransform: CubeTransform(),
              autoSliderDelay: Duration(milliseconds: 1000),
              autoSliderTransitionTime: Duration(milliseconds: 1000),
              unlimitedMode: true,
              slideBuilder: (index) => value.pages[index],
              itemCount: value.numberOfPages,
              controller: value.controller,
              scrollPhysics: NeverScrollableScrollPhysics(),
            ),

            // PageView.builder(
            //   controller: value.controller,
            //   physics: const NeverScrollableScrollPhysics(),
            //   itemCount: value.numberOfPages,
            //   onPageChanged: (index) {
            //     value.currentPage = index;
            //   },
            //   itemBuilder: (context, index) => value.pages[index],
            // ),
            Positioned(
              bottom: 40,
              left: 30,
              right: 35,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: (value.currentPage! > 0 &&
                        value.currentPage! < value.pages.length - 1),
                    child: CustomButton(
                      height: 60,
                      width: 60,
                      insideColor: AppColors.accent,
                      outsideColor: AppColors.primary,
                      child: GestureDetector(
                        onTap: (value.currentPage! > 0)
                            ? value.goToPreviousPage
                            : null,
                        child:
                            //         Row(
                            //           crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //           children: [
                            Image.asset(
                          'assets/images/Screenshot_from_2023-12-11_16-05-36-removebg-preview (1).png',
                          height: 30,
                        ),
                        //     Text(
                        //       'Back',
                        //      style:  GoogleFonts.khula(fontSize: 20),
                        //     ),
                        //   ],
                        // ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: value.currentPage! < value.pages.length - 1,
                    child: CustomButton(
                      height: 60,
                      width: 60,
                      insideColor: AppColors.ternary,
                      outsideColor: AppColors.dark,
                      child: GestureDetector(
                          onTap:
                              // (value.currentPage! < value.numberOfPages - 1) ||
                              //         ((value.currentPage == 1) &&
                              //             value.isEsignButtonClicked) ?
                              value.goToNextPage,
                          //     : () => Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) => CongratsPage(),
                          //           ),
                          //         ),

                          // Navigator.pushNamed(context, route.congratsPage),
                          // style: ElevatedButton.styleFrom(
                          //   backgroundColor: (value.currentPage == 0)
                          //       ? Colors.blue
                          //       : (value.isEsignButtonClicked
                          //           ? Colors.blue
                          //           : Colors.grey),
                          // ),
                          child:
                              // Text(
                              //   value.currentPage != 2 ? 'Next' : "Finsh",
                              //   style:  GoogleFonts.khula(fontSize: 20,)

                              // ),
                              Image.asset(
                            'assets/images/Screenshot_from_2023-12-11_16-05-51-removebg-preview.png',
                            height: 30,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// body: Stack(
      //   children: [
      //     CarouselSlider.builder(
      //       slideTransform: const CubeTransform(),
      //       autoSliderDelay: const Duration(milliseconds: 1000),
      //       autoSliderTransitionTime: const Duration(milliseconds: 1000),
      //       unlimitedMode: true,
      //       slideBuilder: (index) => pages[index],
      //       itemCount: numberOfPages,
      //       controller: controller,
      //       scrollPhysics: const NeverScrollableScrollPhysics(),
      //     ),
      //     Positioned(
      //       bottom: 40,
      //       left: 30,
      //       right: 35,
      //       child: Row(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Visibility(
      //             visible: (currentPage! > 0
      //                 // &&
      //                 //     value.currentPage! < value.pages.length - 1
      //                 ),
      //             child: MyFAB(
      //               icon: Image.asset(
      //                 'assets/images/Leftdoublearrow.png',
      //                 height: 45,
      //                 width: 45,
      //               ),
      //               onPressed: (currentPage! > 0) ? goToPreviousPage : null,
      //             ),
      //           ),
      //           Visibility(
      //             visible: currentPage! < pages.length - 1,
      //             child: MyFAB(
      //               icon: Image.asset(
      //                 'assets/images/Rightdoublearrow.png',
      //                 height: 45,
      //                 width: 45,
      //               ),
      //               onPressed: goToNextPage,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),