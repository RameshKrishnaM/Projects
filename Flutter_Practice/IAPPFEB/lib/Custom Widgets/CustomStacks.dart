import '../API call/api_call.dart';
import '../Custom%20Widgets/StepWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'alertbox.dart';

class MobileImage extends StatelessWidget {
  const MobileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            "Congratulations !",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 20.0, color: const Color.fromRGBO(255, 255, 255, 1)),
          ),
          const SizedBox(height: 10),
          Text(
            "Your are now Free from BROKERAGE",
            style: TextStyle(
                height: 1,
                fontSize: 14.0,
                color: const Color.fromRGBO(255, 255, 255, 1)),
          ),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 40.0),
                child: Image.asset(
                  'assets/images/mobile.png',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 50.0, right: 13.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Image.asset(
                  filterQuality: FilterQuality.high,
                  'assets/images/FlatTrade Logo 2.png',
                  width: 37.0,
                  height: 8.0,
                ),
              ),
            ],
          ),
          // Container(
          //   margin: const EdgeInsets.only(right: 15.0, bottom: 10.0),
          //   child: Text(
          //     'Congratulations',
          //     style: Theme.of(context)
          //         .textTheme
          //         .bodyLarge!
          //         .copyWith(fontWeight: FontWeight.w600, fontSize: 18.0),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class TitleContainer extends StatelessWidget {
  const TitleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 22.0,
              width: 22.0,
            ),
            const Expanded(child: Text('')),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Image.asset(
            //       'assets/images/FlatTrade Logo 1.png',
            //       width: 123.0,
            //       height: 14.03,
            //     ),
            //     // const SizedBox(
            //     //   height: 5.0,
            //     // ),
            //     Text(
            //       'Absolute Zero Brokerage',
            //       style: Theme.of(context)
            //           .textTheme
            //           .bodySmall!
            //           .copyWith(color: const Color.fromRGBO(171, 171, 171, 1)),
            //     )
            //   ],
            // ),
            Image.network(
              "https://flattrade.s3.ap-south-1.amazonaws.com/instakyc/Insta_kyc_logo2.png",
              width: 150.0,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox();
              },
            ),
            const Expanded(child: Text('')),
            GestureDetector(
              child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20.0)),
                  child:
                      //  Icon(
                      //   Icons.power_settings_new,
                      //   color: Colors.white,
                      //   size: 20.0,
                      // )
                      SvgPicture.asset(
                    "assets/images/person.svg",
                    height: 22.0,
                    width: 22.0,
                  )),
              onTap: () =>
                  // openAlertBox(
                  //     context: context,
                  //     content: "Do you want to logout?",
                  //     onpressedButton1: () =>
                  //         logout(context)),
                  helpBottomSheet(context),
            ),
            // GestureDetector(
            //   child: Container(
            //       padding: const EdgeInsets.all(5),
            //       decoration: BoxDecoration(
            //           color: Theme.of(context).colorScheme.primary,
            //           borderRadius: BorderRadius.circular(20.0)),
            //       child: SvgPicture.asset(
            //         "assets/images/person.svg",
            //         height: 22.0,
            //         width: 22.0,
            //       )),
            //   onTap: () => helpBottomSheet(context),
            // )
          ],
        ),
      ),
    );
  }
}
