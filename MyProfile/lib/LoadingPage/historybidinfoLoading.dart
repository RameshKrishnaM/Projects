// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class IpoHistoryInfoLoading extends StatefulWidget {
  const IpoHistoryInfoLoading({super.key});

  @override
  State<IpoHistoryInfoLoading> createState() => _IpoHistoryInfoLoadingState();
}

class _IpoHistoryInfoLoadingState extends State<IpoHistoryInfoLoading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(227, 242, 253, 1),
                  border: Border.all(
                      color:
                          Provider.of<NavigationProvider>(context).themeMode ==
                                  ThemeMode.dark
                              ? Colors.white10 // Light mode
                              : const Color.fromRGBO(235, 237, 236, 1)),
                  boxShadow:
                      Provider.of<NavigationProvider>(context).themeMode ==
                              ThemeMode.dark
                          ? null
                          : [
                              BoxShadow(
                                color: const Color.fromARGB(255, 230, 228, 228)
                                    .withOpacity(0.5),
                                offset: const Offset(0,
                                    1.0), // Offset (x, y) controls the shadow's position
                                blurRadius: 15, // Spread of the shadow
                                spreadRadius:
                                    5.0, // Positive values expand the shadow, negative values shrink it
                              ),
                            ],
                  borderRadius: BorderRadius.circular(8.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPI ID',
                        style:
                            TextStyle(fontSize: 12.0, color: subTitleTextColor),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        width: 30,
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white12,
                          backgroundColor: Colors.grey.shade400,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Category',
                          style: TextStyle(
                              fontSize: 12.0, color: subTitleTextColor)),
                      const SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        width: 30,
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white12,
                          backgroundColor: Colors.grey.shade400,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Amt. Payable',
                            style: TextStyle(
                                fontSize: 12.0, color: subTitleTextColor)),
                        const SizedBox(
                          height: 5.0,
                        ),
                        SizedBox(
                          width: 30,
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white12,
                            backgroundColor: Colors.grey.shade400,
                          ),
                        )
                      ]),
                ],
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(94, 151, 136, 136),
                      width: 0.7 // Light mode

                      ),
                  borderRadius: BorderRadius.circular(7.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No.of Lot',
                        style:
                            TextStyle(fontSize: 12.0, color: subTitleTextColor),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        width: 30,
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white12,
                          backgroundColor: Colors.grey.shade400,
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Cutoff-Price',
                          style: TextStyle(
                              fontSize: 12.0, color: subTitleTextColor)),
                      const SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        width: 30,
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white12,
                          backgroundColor: Colors.grey.shade400,
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(' Price',
                          style: TextStyle(
                              fontSize: 12.0, color: subTitleTextColor)),
                      const SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        width: 30,
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white12,
                          backgroundColor: Colors.grey.shade400,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 30,
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white12,
                      backgroundColor: Colors.grey.shade400,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
