// ignore_for_file: use_build_context_synchronousl

import 'package:flutter/material.dart';
import 'package:project2/backgroundAnimatedContainer.dart';
import 'package:project2/fileuploading.dart';
import 'package:project2/pageSwap.dart';
import 'package:project2/style.dart';
import 'package:provider/provider.dart';

class LastStep extends StatefulWidget {
  const LastStep({super.key});

  @override
  State<LastStep> createState() => _LastStepState();
}

class _LastStepState extends State<LastStep> {
  @override
  Widget build(BuildContext context) {
    var image = Provider.of<FileUploading>(context, listen: false);
    var pageSwap = Provider.of<PageSwap>(context, listen: false);

    Future<void> onYesButtonPressed() async {
      if (image.isLoading) {
        const CircularProgressIndicator();
      } else {
        await image.pickFile();

        if (image.pickedFile != null) {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Image:',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.asset(
                        'assets/images/${image.fileName ?? const FlutterLogo()}',
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('no'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            pageSwap.esignButtonClicked();
                          },
                          child: const Text('confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    void showAlertBox() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Can we access your files',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await onYesButtonPressed();
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'No',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
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
                        // 'assets/images/Screenshot_from_2023-12-19_16-05-36-removebg-preview.png',
                        'assets/images/Screenshot_from_2023-12-19_16-10-45-removebg-preview.png',
                        height: 300,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Last Step!',
                          textAlign: TextAlign.center,
                          style: AppFont.heading(textColor: AppColors.primary)
                              .primary),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                          'The last step is to digitally sign your application form(s). We will e-mail you your login credentials once your forms are verified.',
                          style: AppFont.body(textColor: AppColors.dark)
                              .secondary),
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              showAlertBox();
                            },
                            child: Text('ESIGN',
                                style: AppFont.body(textColor: AppColors.light)
                                    .secondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 150),
              ],
            ),
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
    path.lineTo(0, h);
    path.lineTo(h * 4 / 3, w * 4 / 4);
    path.lineTo(w, 0);
    // path.lineTo(0, h);
    path.lineTo(h * 8 / 3, w * 4 / 4);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
