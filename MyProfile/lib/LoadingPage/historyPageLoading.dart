// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class HistoryPageLoadingFeild extends StatefulWidget {
  const HistoryPageLoadingFeild({super.key});

  @override
  State<HistoryPageLoadingFeild> createState() =>
      _HistoryPageLoadingFeildState();
}

class _HistoryPageLoadingFeildState extends State<HistoryPageLoadingFeild>
    with TickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
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
          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 60,
                  child: ListTile(
                      title: SizedBox(
                        height: titleFontSize - 2,
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(100),
                          value: controller.value,
                          backgroundColor: titleTextColorLight.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            titleTextColorDark.withOpacity(0.2),
                          ),
                          semanticsLabel: 'Linear progress indicator',
                        ),
                      ),
                      subtitle: SizedBox(
                        width: 90,
                        height: titleFontSize - 2,
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(100),
                          value: controller.value,
                          backgroundColor: titleTextColorLight.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            titleTextColorDark.withOpacity(0.2),
                          ),
                          semanticsLabel: 'Linear progress indicator',
                        ),
                      ),
                      trailing: SizedBox(
                        width: 90,
                        height: titleFontSize - 2,
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(100),
                          value: controller.value,
                          backgroundColor: titleTextColorLight.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            titleTextColorDark.withOpacity(0.2),
                          ),
                          semanticsLabel: 'Linear progress indicator',
                        ),
                      )),
                ),
              ]);
        },
      ),
    );
  }
}
