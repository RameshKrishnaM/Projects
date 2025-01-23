import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/provider.dart';
import '../../utils/colors.dart';

customAlertBox(
    {required BuildContext context, required String content, required func1}) {
  Color themeBasedColor =
      Provider.of<NavigationProvider>(context, listen: false).themeMode ==
              ThemeMode.dark
          ? titleTextColorDark
          : titleTextColorLight;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24.0))),
        contentPadding: EdgeInsets.all(20),
        content: Text(
          content,
          style: TextStyle(
              fontSize: 13.0,
              color: themeBasedColor,
              fontWeight: FontWeight.bold),
        ),
        actionsPadding: EdgeInsets.only(bottom: 20, right: 20, top: 10),
        actions: [
          SizedBox(
            height: 25.0,
            child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStatePropertyAll(
                        Provider.of<NavigationProvider>(context).themeMode ==
                                ThemeMode.dark
                            ? Colors.white
                            : appPrimeColor)),
                onPressed: func1,
                child: Text(
                  'Yes',
                  style: TextStyle(
                      fontFamily: 'inter',
                      fontSize: 12.0,
                      color:
                          Provider.of<NavigationProvider>(context).themeMode ==
                                  ThemeMode.dark
                              ? Colors.black
                              : Colors.white),
                )),
          ),
          SizedBox(
            height: 25.0,
            child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStatePropertyAll(
                        Provider.of<NavigationProvider>(context).themeMode ==
                                ThemeMode.dark
                            ? Colors.white
                            : appPrimeColor)),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('No',
                    style: TextStyle(
                        fontFamily: 'inter',
                        fontSize: 12.0,
                        color: Provider.of<NavigationProvider>(context)
                                    .themeMode ==
                                ThemeMode.dark
                            ? Colors.black
                            : Colors.white))),
          ),
        ],
      );
    },
  );
}
