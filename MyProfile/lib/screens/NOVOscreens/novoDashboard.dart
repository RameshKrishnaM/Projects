import 'package:flutter/material.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/novoModels/dashboardmodel.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/NOVO%20Widgets/customLoadingAni.dart';
import 'package:provider/provider.dart';

class NovoHome extends StatefulWidget {
  List<SegmentArr> dashboardDetails;
  NovoHome({super.key, required this.dashboardDetails});

  @override
  State<NovoHome> createState() => _NovoHomeState();
}

class _NovoHomeState extends State<NovoHome> {
  // NovoDashBoardDetails? novoDashBoardData;
  // List<SegmentArr> novoDashBoardDataList = [];
  // bool isLoading = true;
  // @override
  // void initState() {
  //   super.initState();
  //   // getDashBoardData();
  // }

  // getDashBoardData() async {
  //   novoDashBoardData = await fetchNovoDashBoardDetails(context: context);

  //   if (novoDashBoardData != null && novoDashBoardData!.segmentArr != null) {
  //     novoDashBoardDataList = novoDashBoardData!.segmentArr!
  //         .where((e) => e.status!.toUpperCase() == 'Y')
  //         .toList();
  //   } else {
  //     novoDashBoardDataList = [];
  //   }

  //   setState(() {});

  //   isLoading = false;
  // }

  @override
  Widget build(BuildContext context) {
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          // color: Colors.red,
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Primary Market',
                style: TextStyle(
                    color: Provider.of<NavigationProvider>(context).themeMode ==
                            ThemeMode.dark
                        ? titleTextColorDark
                        : titleTextColorLight,
                    fontSize: 25,
                    letterSpacing: 1.2,
                    fontFamily: 'Kiro',
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'Start Your Investment Journey',
                style: TextStyle(
                    color: Provider.of<NavigationProvider>(context).themeMode ==
                            ThemeMode.dark
                        ? titleTextColorDark
                        : titleTextColorLight,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'Invest in IPO, zero commission Direct Mutual Funds, Sovereign Gold Bonds, and Government Bills',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: subTitleFontSize, fontFamily: 'inter'),
              ),
            ],
          ),
        ),
        // isLoading
        //     ? const Expanded(child: Center(child: loadingProgress()))
        //     :
        widget.dashboardDetails.isEmpty ||
                widget.dashboardDetails.isEmpty == null
            ? Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Something went wrong, Please Retry...'),
                    IconButton(
                        iconSize: 30,
                        splashColor: appPrimeColor,
                        splashRadius: 20,
                        onPressed: () async {
                          await fetchNovoDashBoardDetails(context: context);
                        },
                        icon: const Icon(Icons.refresh_outlined)),
                  ],
                ),
              )
            : Expanded(
                child: Container(
                  margin: const EdgeInsets.all(40.0),
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 30.0,
                              mainAxisSpacing: 25.0),
                      itemCount: widget.dashboardDetails.length,
                      itemBuilder: (BuildContext context, int index) {
                        return widget.dashboardDetails
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  ChangeIndex().value =
                                      widget.dashboardDetails.indexOf(e) + 1;
                                },
                                child: Visibility(
                                  visible:
                                      widget.dashboardDetails[index].status ==
                                          'Y',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: darkThemeMode
                                              ? const Color.fromARGB(
                                                      255, 230, 228, 228)
                                                  .withOpacity(0.1)
                                              : Colors.grey.shade200
                                                  .withOpacity(0.9),
                                          offset: const Offset(
                                            5.0,
                                            5.0,
                                          ),
                                          blurRadius: 20.0,
                                          spreadRadius: 10.0,
                                        ), //BoxShadow
                                        BoxShadow(
                                          color: darkThemeMode
                                              ? const Color.fromRGBO(
                                                  48, 48, 48, 1)
                                              : Colors.white,
                                          offset: const Offset(
                                            0.0,
                                            0.0,
                                          ),
                                          blurRadius: 0.0,
                                          spreadRadius: 5.0,
                                        ), //BoxShadow
                                      ],
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        darkThemeMode
                                            ? Image.network(
                                                '${widget.dashboardDetails[index].darkThemeImage}',
                                                width: widget
                                                            .dashboardDetails[
                                                                index]
                                                            .path ==
                                                        '/sgb'
                                                    ? 82
                                                    : 60,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const SizedBox(),
                                              )
                                            : Image.network(
                                                '${widget.dashboardDetails[index].image}',
                                                width: widget
                                                            .dashboardDetails[
                                                                index]
                                                            .path ==
                                                        '/sgb'
                                                    ? 82
                                                    : 60,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const SizedBox(),
                                              ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          widget.dashboardDetails[index].name!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              fontFamily: 'Kiro'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList()[index];

                        //     InkWell(
                        //   onTap: widget.dashboardDetails[index].status == 'Y'
                        //       ? () {
                        //           print(widget.dashboardDetails[index].path);
                        //           ChangeIndex().value = widget
                        //                       .dashboardDetails[index].path ==
                        //                   '/ipo'
                        //               ? 1
                        //               : widget.dashboardDetails[index].path ==
                        //                       '/sgb'
                        //                   ? 2
                        //                   : widget.dashboardDetails[index]
                        //                               .path ==
                        //                           '/gsec'
                        //                       ? 3
                        //                       : 0;
                        //           print(ChangeIndex().getIndex);
                        //         }
                        //       : null,
                        //   child: Visibility(
                        //     visible:
                        //         widget.dashboardDetails[index].status == 'Y',
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: darkThemeMode
                        //                 ? const Color.fromARGB(
                        //                         255, 230, 228, 228)
                        //                     .withOpacity(0.1)
                        //                 : Colors.grey.shade200.withOpacity(0.9),
                        //             offset: const Offset(
                        //               5.0,
                        //               5.0,
                        //             ),
                        //             blurRadius: 20.0,
                        //             spreadRadius: 10.0,
                        //           ), //BoxShadow
                        //           BoxShadow(
                        //             color: darkThemeMode
                        //                 ? const Color.fromRGBO(48, 48, 48, 1)
                        //                 : Colors.white,
                        //             offset: const Offset(
                        //               0.0,
                        //               0.0,
                        //             ),
                        //             blurRadius: 0.0,
                        //             spreadRadius: 5.0,
                        //           ), //BoxShadow
                        //         ],
                        //         borderRadius: BorderRadius.circular(10.0),
                        //       ),
                        //       child: Column(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         children: [
                        //           darkThemeMode
                        //               ? Image.network(
                        //                   '${widget.dashboardDetails[index].darkThemeImage}',
                        //                   width: widget.dashboardDetails[index]
                        //                               .path ==
                        //                           '/sgb'
                        //                       ? 82
                        //                       : 60,
                        //                   errorBuilder:
                        //                       (context, error, stackTrace) =>
                        //                           const SizedBox(),
                        //                 )
                        //               : Image.network(
                        //                   '${widget.dashboardDetails[index].image}',
                        //                   width: widget.dashboardDetails[index]
                        //                               .path ==
                        //                           '/sgb'
                        //                       ? 82
                        //                       : 60,
                        //                   errorBuilder:
                        //                       (context, error, stackTrace) =>
                        //                           const SizedBox(),
                        //                 ),
                        //           const SizedBox(
                        //             height: 10.0,
                        //           ),
                        //           Text(
                        //             widget.dashboardDetails[index].name!,
                        //             style: const TextStyle(
                        //                 fontWeight: FontWeight.bold,
                        //                 fontSize: 20,
                        //                 fontFamily: 'Kiro'),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // );
                      }),
                ),
              ),
      ],
    );
  }
}
