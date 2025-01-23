import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:project2/customButton.dart';
import 'package:project2/pageSwap.dart';
import 'package:project2/style.dart';
import 'package:project2/userDetails.dart';
import 'package:provider/provider.dart';

class CongratsPage extends StatefulWidget {
  const CongratsPage({Key? key}) : super(key: key);

  @override
  State<CongratsPage> createState() => _CongratsPageState();
}

class _CongratsPageState extends State<CongratsPage> {
  @override
  void initState() {
    super.initState();
    initial();
  }

  initial() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAlert();
    });
  }

  showAlert() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              // Image.asset(
              //   'assets/images/Screenshot from 2023-12-13 12-39-48.png',
              //   height: 40,
              // ),
              Text('User Details',
                  style: AppFont.heading(
                          textColor: AppColors.darkPrimary,
                          fontWeight: FontWeight.w600)
                      .secondary),
              // ]),
              IconButton(
                onPressed: () {
                  context.read<PageSwap>().goToPreviousPage();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_sharp),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(0, 0, 25, 30),
          titlePadding:
              const EdgeInsets.only(left: 20.0, right: 0, bottom: 0, top: 0),
          contentPadding:
              const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
          content: const UserDetails(),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            CustomButton(
                insideColor: AppColors.accent,
                height: 30,
                width: 60,
                outsideColor: AppColors.darkPrimary,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                )),
          ],
        );
      },
    );
  }

  void showSnackBar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Application downloaded successfully',
                style: AppFont.body(
                        textColor: AppColors.light, fontWeight: FontWeight.bold)
                    .secondary),
            Image.asset(
              'assets/images/Screenshot_from_2023-12-12_14-15-14-removebg-preview.png',
              height: 40,
            )
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  bool isDownload = true;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.only(bottom: 50),
            color: AppColors.light,
            height: 560,
            alignment: Alignment.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/Screenshot_from_2023-12-20_17-59-24-removebg-preview.png',
                    // 'assets/images/Animation - 1702538829806.gif',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/images/pops.gif'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset('assets/images/pops.gif'),
                  ),
                ],
              ),
              Center(
                child: Text('Your application is completed',
                    style: AppFont.subtitle(
                            textColor: AppColors.darkPrimary,
                            fontWeight: FontWeight.w700)
                        .primary),
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                        style: const TextStyle(height: 1.2),
                        children: [
                          TextSpan(
                              text:
                                  'Verification of the application could take up to 72 hours at the exchange based on your KYC status. After verification, you will receive an email with your login credentials. In the meanwhile, you can check out ',
                              style: AppFont.body(
                                textColor: AppColors.dark,
                              ).secondary),
                          TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = () {},
                              text: 'this guide to getting started.',
                              style: AppFont.body(
                                textColor: AppColors.primary,
                              ).secondary),
                        ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                          style: const TextStyle(height: 1.2),
                          children: [
                            TextSpan(
                                text:
                                    'Refer your friends and family with this link and earn reward points. These points can be redeemed for subscriptions to our partner products like Sensibull, Smallcase, and Streak.',
                                style: AppFont.body(
                                  textColor: AppColors.dark,
                                ).secondary)
                          ]))
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              CustomButton(
                height: 55,
                width: 230,
                insideColor: AppColors.darkPrimary,
                outsideColor: AppColors.dark,
                child: GestureDetector(
                  onTap: isDownload
                      ? () async {
                          setState(() {
                            isDownload = false;
                            showSnackBar();
                          });
                        }
                      : null,
                  child: isDownload
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Download Application',
                                style: AppFont.body(
                                  textColor: AppColors.light,
                                  fontWeight: FontWeight.w700,
                                ).secondary),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Application Downloaded',
                                style: AppFont.body(
                                  textColor: AppColors.light,
                                  fontWeight: FontWeight.w700,
                                ).secondary),
                            Image.asset(
                              'assets/images/Screenshot_from_2023-12-12_14-13-51-removebg-preview.png',
                              height: 60,
                            )
                          ],
                        ),
                ),
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  // @override
  // Path getClip(Size size) {
  //   double w = size.width;
  //   double h = size.height;
  //   Path path = Path();
  //   path.lineTo(0, h);
  //   path.lineTo(h * 4 / 7, w * 4 / 4);
  //   path.lineTo(w, 0);
  //   path.lineTo(0, h);
  //   path.lineTo(w, 0);
  //   path.lineTo(0, h);
  //   path.close();

  //   return path;
  // }

  // @override
  // bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
  //   return false;
  // }
// }

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path();
    path.lineTo(h * 4 / 15, w * 4 / 14);
    path.lineTo(w, 0);
    path.lineTo(0, h);
    path.lineTo(w * 3, 0);
    path.lineTo(0, h * 4);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
