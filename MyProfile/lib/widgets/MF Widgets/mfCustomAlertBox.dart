import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';

customMfAlertBox({
  required BuildContext context,
  required dynamic title,
  required Widget contentWidget,
  String? type,
  required func1,
}) {
  // Color themeBasedColor =
  //     Provider.of<NavigationProvider>(context, listen: false).themeMode ==
  //             ThemeMode.dark
  //         ? titleTextColorDark
  //         : titleTextColorLight;
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24.0))),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            child: Container(
              constraints: BoxConstraints(
                  minHeight: 10,
                  maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: title is String
                              ? Text(
                                  title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                )
                              : title,
                        ),
                      ),
                    ],
                  ),
                  type == 'cartStatus'
                      ? Flexible(child: contentWidget)
                      : Center(child: contentWidget),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                            color: primaryRedColor.withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24))),
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: primaryRedColor,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
