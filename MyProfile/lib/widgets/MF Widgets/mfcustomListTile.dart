// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

import 'imagedecoderWidget.dart';

class MFCustomListTile extends StatelessWidget {
  final String title;
  final dynamic imageUrl;
  final Widget subtitl1, subtitle2;
  final Widget? tailingWidget, subtitle3;
  final double? tailingWidgetWidth;
  final bool? noNeedFittedBoxInTrailing;
  final Widget? titleWidget;
  final double? titlepadding;
  final Color? selectedColor;
  final bool? showImage;

  const MFCustomListTile({
    super.key,
    required this.imageUrl,
    this.showImage = true,
    required this.title,
    required this.subtitl1,
    required this.subtitle2,
    this.titlepadding,
    this.subtitle3,
    this.tailingWidget,
    this.noNeedFittedBoxInTrailing,
    this.tailingWidgetWidth,
    this.titleWidget,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    return Container(
        padding: const EdgeInsets.only(left: 5, bottom: 5),
        width: double.infinity,
        decoration: BoxDecoration(
            color: darkThemeMode
                ? const Color.fromARGB(255, 54, 54, 54)
                : const Color.fromRGBO(248, 248, 247, 1),
            border: Border(
                left: BorderSide(
                    color: selectedColor == null
                        ? darkThemeMode
                            ? const Color.fromARGB(255, 54, 54, 54)
                            : const Color.fromRGBO(248, 248, 247, 1)
                        : selectedColor!,
                    width: 4)),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showImage == true
                ? Container(
                    width: 50.0,
                    height: 50.0,
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: imageUrl is String
                        ? imageUrl.isNotEmpty
                            ?
                            // Image.network(imageUrl)
                            ImageLoader(
                                loadingImg: imageUrl,
                              )
                            : const SizedBox()
                        : imageUrl,
                  )
                : SizedBox(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: titlepadding ?? 10, bottom: 5, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Text(
                          title,
                          textAlign: TextAlign.start,
                          style: darkThemeMode
                              ? ThemeClass.Darktheme.textTheme.bodySmall!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      height: 1.4,
                                      color: titleTextColorDark)
                              : ThemeClass.lighttheme.textTheme.bodySmall!
                                  .copyWith(
                                      fontSize: 13,
                                      height: 1.4,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                        )),
                        if (titleWidget != null) ...[
                          const SizedBox(
                            width: 5.0,
                          ),
                          titleWidget!
                        ]
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Wrap subtitl1 and subtitle2 with Flexible to manage their space properly
                        subtitl1,
                        subtitle2,
                      ],
                    ),
                  ),
                  if (subtitle3 != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: subtitle3!,
                    )
                  else
                    SizedBox()
                ],
              ),
            ),
            if (tailingWidget != null)
              SizedBox(
                // color: Colors.red,
                width: tailingWidgetWidth ?? 55,
                child: noNeedFittedBoxInTrailing == true
                    ? tailingWidget
                    : tailingWidget!,
              )
          ],
        ));
  }
}
