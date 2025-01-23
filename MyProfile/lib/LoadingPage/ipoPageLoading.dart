// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class IpoPageLoadingFeild extends StatefulWidget {
  const IpoPageLoadingFeild({super.key});

  @override
  State<IpoPageLoadingFeild> createState() => _IpoPageLoadingFeildState();
}

class _IpoPageLoadingFeildState extends State<IpoPageLoadingFeild>
    with TickerProviderStateMixin {
  late AnimationController controller;
  // late Animation<Color?> animationColor;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(
            color: Provider.of<NavigationProvider>(context).themeMode ==
                    ThemeMode.dark
                ? Colors.white10 // Light mode
                : const Color.fromRGBO(235, 237, 236, 1),
            thickness: 1.5,
          );
        },
        itemCount: 15,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: titleFontSize - 2,
                          child: LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(100),
                            value: controller.value,
                            backgroundColor:
                                titleTextColorLight.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              titleTextColorDark.withOpacity(0.2),
                            ),
                            semanticsLabel: 'Linear progress indicator',
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 6.0,
                    ),
                    SizedBox(
                      width: 180,
                      height: subTitleFontSize - 2,
                      child: LinearProgressIndicator(
                        backgroundColor: titleTextColorLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                        value: controller.value,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          titleTextColorDark.withOpacity(0.2),
                        ),
                        semanticsLabel: 'Linear progress indicator',
                      ),
                    ),
                    const SizedBox(
                      height: 2.0,
                    ),
                    SizedBox(
                      width: 70,
                      height: contentFontSize,
                      child: LinearProgressIndicator(
                        backgroundColor: titleTextColorLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                        value: controller.value,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          titleTextColorDark.withOpacity(0.2),
                        ),
                        semanticsLabel: 'Linear progress indicator',
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 20,
                      child: LinearProgressIndicator(
                        backgroundColor: titleTextColorLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                        value: controller.value,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          titleTextColorDark.withOpacity(0.2),
                        ),
                        semanticsLabel: 'Linear progress indicator',
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    SizedBox(
                      width: 70,
                      height: contentFontSize,
                      child: LinearProgressIndicator(
                        backgroundColor: titleTextColorLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                        value: controller.value,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          titleTextColorDark.withOpacity(0.2),
                        ),
                        semanticsLabel: 'Linear progress indicator',
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
