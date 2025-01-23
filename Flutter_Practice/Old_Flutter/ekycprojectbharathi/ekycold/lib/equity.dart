import 'package:ekycold/backgroundAnimatedContainer.dart';
import 'package:ekycold/style.dart';
import 'package:flutter/material.dart';

class Equity extends StatefulWidget {
  const Equity({super.key});

  @override
  State<Equity> createState() => _EquityState();
}

class _EquityState extends State<Equity> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
  }

  bool buttonClicked = false;
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
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'PAN Details',
                  style: AppFont.subtitle(
                          textColor: AppColors.dark,
                          fontWeight: FontWeight.w700)
                      .primary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.cancel_sharp),
              ),
            ],
          ),
          titlePadding:
              EdgeInsets.only(left: 20.0, right: 0, bottom: 0, top: 0),
          contentPadding:
              EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your PAN',
                style: AppFont.body(textColor: AppColors.dark).primary,
              ),
              Text(
                'LVZPS0459L',
                style: AppFont.subtitle(
                        textColor: AppColors.primary,
                        fontWeight: FontWeight.w800)
                    .primary,
              ),
              const SizedBox(
                height: 20,
              ),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: '* ',
                    style: AppFont.subtitle(
                            textColor: AppColors.primary,
                            fontWeight: FontWeight.bold)
                        .primary),
                TextSpan(
                    text:
                        'This PAN should belong to you, the applicant. If it does not, ',
                    style: AppFont.body(textColor: AppColors.semiDark).primary),
                WidgetSpan(
                    child: GestureDetector(
                  child: Text('start over',
                      style: AppFont.body(textColor: Colors.green).primary),
                  onTap: () {},
                ))
              ])),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            child: Stack(
          children: <Widget>[
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
          ],
        )),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text('Equity',
                  style: AppFont.subtitle(
                          textColor: AppColors.primary,
                          fontWeight: FontWeight.w600)
                      .primary),
              const SizedBox(height: 20),
              Text(
                  'This will be your account to buy and sell shares, mutual funds, and derivatives on NSE and BSE.',
                  textAlign: TextAlign.justify,
                  style: AppFont.body(textColor: AppColors.dark).primary),
              const SizedBox(height: 10),
              Text.rich(
                textAlign: TextAlign.justify,
                TextSpan(
                  children: [
                    TextSpan(
                        text:
                            "Don't have Aadhar and mobile linked to eSign? Download ",
                        style: AppFont.body(
                          textColor: AppColors.semiLight,
                        ).primary),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {},
                        child: Text('Equity form',
                            style: AppFont.body(
                              textColor: AppColors.primary,
                            ).primary),
                      ),
                    ),
                    TextSpan(
                        text: ' and courier it to us. ',
                        style: AppFont.body(
                          textColor: AppColors.semiLight,
                        ).primary),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {},
                        child: Text('Learn more',
                            style: AppFont.body(
                              textColor: Colors.red.shade400,
                            ).primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {},
                child: Text('Enable commodity account',
                    style: AppFont.subtitle(
                            textColor: AppColors.secondary,
                            fontWeight: FontWeight.w600)
                        .primary),
              ),
              SizedBox(
                height: 30,
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * .4,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    BackgroundAnimatedContainer(linerColors: [
                      AppColors.darkSecondary,
                      AppColors.darkTernary,
                      AppColors.primary,
                      AppColors.ternary
                    ]),
                    Image.asset(
                      'assets/img/Screenshot_from_2023-12-12_18-33-00-removebg-preview (1).png',
                      height: 220,
                    )
                  ],
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     OutlinedButton(
              //       style: ButtonStyle(
              //         side: MaterialStateProperty.all(
              //             const BorderSide(color: Colors.blue)),
              //       ),
              //       onPressed: () {},
              //       child: const Text('Back', style: TextStyle(fontSize: 18)),
              //     ),
              //     ElevatedButton(kground remover
              //       onPressed: () async {
              //         setState(() {
              //           buttonClicked = true;
              //         });
              //         // await Future.delayed(const Duration(milliseconds: 300));
              //         Navigator.pushNamed(context, route.congratsPage);
              //         // await Future.delayed(const Duration(milliseconds: 300));
              //         // Navigator.push(
              //         //   context,
              //         //   PageRouteBuilder(
              //         //     pageBuilder: (_, __, ___) => const CongratsPage(),
              //         //     transitionsBuilder: (_, animation, __, child) {
              //         //       return FadeTransition(
              //         //         opacity: animation,
              //         //         child: child,
              //         //       );
              //         //     },
              //         //   ),
              //         // );
              //       },
              //       style: ButtonStyle(
              //         backgroundColor: buttonClicked
              //             ? MaterialStateProperty.all<Color>(Colors.green)
              //             : MaterialStateProperty.all<Color>(Colors.blue),
              //       ),
              //       child: const Text(
              //         'Finish',
              //         style: TextStyle(fontSize: 18),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path();
    // remove Move step
    path.lineTo(0, h);
    path.lineTo(w * 1 / 7, h);
    path.lineTo(w, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
