// ignore_for_file: use_build_context_synchronously

import 'package:ekycold/backgroundAnimatedContainer.dart';
import 'package:ekycold/fileuploading.dart';
import 'package:ekycold/pageSwap.dart';
import 'package:ekycold/style.dart';
import 'package:flutter/material.dart';
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
        CircularProgressIndicator();
      } else {
        await image.pickFile();

        if (image.pickedFile != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Image:',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.asset(
                        'assets/images/${image.fileName ?? FlutterLogo()}',
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('no'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            await Future.delayed(Duration(milliseconds: 500));
                            pageSwap.esignButtonClicked();
                          },
                          child: Text('confirm'),
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
                Text(
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
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
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
            padding: EdgeInsets.only(bottom: 50),
            color: AppColors.light,
            height: 560,
            alignment: Alignment.center,
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
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
                        // 'assets/img/Screenshot_from_2023-12-19_16-05-36-removebg-preview.png',
                        'assets/img/Screenshot_from_2023-12-19_16-10-45-removebg-preview.png',
                        height: 300,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Last Step!',
                          textAlign: TextAlign.center,
                          style: AppFont.heading(textColor: AppColors.primary)
                              .primary),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                          'The last step is to digitally sign your application form(s). We will e-mail you your login credentials once your forms are verified.',
                          style: AppFont.body(textColor: AppColors.dark)
                              .secondary),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // showAlertBox();
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
                SizedBox(height: 150),
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
