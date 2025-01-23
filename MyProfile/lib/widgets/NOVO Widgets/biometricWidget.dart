// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class AskBiometric extends StatelessWidget {
  final String title;
  final String content;
  final Function cancelBtn;
  final Function onPress;
  final String buttonText;
  const AskBiometric({
    super.key,
    required this.title,
    required this.cancelBtn,
    required this.onPress,
    required this.content,
    this.buttonText = 'Proceed',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      title: Row(
        children: [
          // Icon(
          //   Icons.fingerprint_outlined,
          //   size: 20,
          // ),
          // SizedBox(
          //   width: 5,
          // ),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 22, fontFamily: 'inter'),
          ),
        ],
      ),
      // titleTextStyle: Theme.of(context).textTheme.bodyLarge,
      content: Text(
        content,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(fontSize: 13, fontFamily: 'inter'),
      ),
      // contentTextStyle: Theme.of(context).textTheme.bodyLarge,
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      // contentPadding: EdgeInsets.only(top: 18, left: 30, right: 30, bottom: 12),
      // contentPadding: EdgeInsets.only(top: 18, left: 30, right: 30, bottom: 0),
      // actionsPadding: EdgeInsets.all(10),
      actions: <Widget>[
        SizedBox(
          height: 28.0,
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: WidgetStatePropertyAll(subTitleTextColor)),
              onPressed: () {
                cancelBtn();
              },
              child: Text('Cancel',
                  style: TextStyle(
                      fontFamily: 'inter',
                      fontSize: 12.0,
                      color: Colors.white))),
        ),
        SizedBox(
          height: 28.0,
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: WidgetStatePropertyAll(
                      // Provider.of<NavigationProvider>(
                      //                 context)
                      //             .themeMode ==
                      //         ThemeMode.dark
                      //     ? Colors.white
                      //     :
                      appPrimeColor)),
              onPressed: () => onPress(),
              child: Text(
                buttonText,
                style: TextStyle(
                    fontFamily: 'inter', fontSize: 12.0, color: Colors.white),
              )),
        ),
        // MaterialButton(
        //   elevation: 0,
        //   minWidth: 100,
        //   color: Color(0xFF8198A6).withOpacity(0.8),
        //   shape: const RoundedRectangleBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(15))),
        //   child: const Text(
        //     'Cancel',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   onPressed: () {
        //     cancelBtn();
        //   },
        // ),
        // MaterialButton(
        //   elevation: 0,
        //   minWidth: 100,
        //   shape: const RoundedRectangleBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(15))),
        //   color: Color.fromRGBO(9, 101, 218, 1),
        //   onPressed: () => onPress(),
        //   child: Text(
        //     buttonText,
        //     style: TextStyle(color: Colors.white),
        //   ),
        // ),
      ],
    );
  }
}
