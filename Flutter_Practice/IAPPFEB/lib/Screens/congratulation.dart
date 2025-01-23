import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Custom%20Widgets/StepWidget.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../API%20call/api_call.dart';
import '../Cookies/HttpClient.dart';
import '../Custom Widgets/alertbox.dart';
import '../Screens/signup.dart';
import '../Service/download_file.dart';
import 'package:flutter/material.dart';
import '../Custom Widgets/CustomStacks.dart';
import '../Custom Widgets/custom_snackBar.dart';
import '../Model/Application_Statu.dart';
import '../Route/route.dart' as route;

class Congratulation extends StatefulWidget {
  const Congratulation({super.key});

  @override
  State<Congratulation> createState() => _CongratulationState();
}

class _CongratulationState extends State<Congratulation> {
  bool isStatusLoaded = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  List? application;
  getApplication() async {
    loadingAlertBox(context);
    application =
        applicationModel == null || applicationModel!.esigneddocid.isEmpty
            ? null
            : await fetchFile(
                context: context,
                id: applicationModel!.esigneddocid,
                list: true);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  ApplicationModel? applicationModel;
  List keys = [];
  fetchData() async {
    loadingAlertBox(context);
    var response = await getFormStatus(context: context);
    if (response != null) {
      applicationModel = applicationModelFromJson(jsonEncode(response));
      // applicationModel!.applicationStatus = "COm";
      keys = applicationModel!.stagemsg.keys.toList();
      isStatusLoaded = false;
    }
    if (mounted) {
      setState(() {});
      Navigator.pop(context);
    }
  }

  // void showSnackbar(String message) {
  //   final snackBar = SnackBar(content: Text(message));
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        openAlertBox(
            context: context,
            content: "Do you want to Exit?",
            onpressedButton1: () => exit(0));
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Rectangle 1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const TitleContainer(),
              Expanded(
                child: ListView(
                  children: [
                    // Stack(
                    //   children: [
                    //     Image.asset(
                    //       'assets/images/clipPath.png',
                    //       width: MediaQuery.of(context).size.width,
                    //       height: MediaQuery.of(context).size.height * 0.45,
                    //       fit: BoxFit.fill,
                    //     ),
                    //     Image.asset(
                    //       'assets/images/pulse.png',
                    //       width: MediaQuery.of(context).size.width,
                    //       height: MediaQuery.of(context).size.height * 0.23,
                    //       fit: BoxFit.fill,
                    //     ),
                    // const MobileImage()
                    //   ],
                    // ),
                    // const SizedBox(
                    //   height: 5.0,
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    //   child: Text(
                    //     'You have succecssfully completed the account opening process',
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .displayMedium!
                    //         .copyWith(fontSize: 18.0),
                    //     textAlign: TextAlign.center,
                    //   ),
                    // ),
                    // const SizedBox(height: 10.0),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Image.asset(
                    //       'assets/images/endSymbol.png',
                    //       width: 52.0,
                    //       height: 52.0,
                    //     )
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.015,
                    // ),
                    const SizedBox(height: 30),
                    Text(
                      "Congratulations!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 18.0,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your are now Free from BROKERAGE!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 20.0),
                    SvgPicture.asset(
                      "assets/images/EKYC Completed Img.svg",
                      width: 180.0,
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          // border: Border.all(),
                          borderRadius: BorderRadius.circular(17),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              color: Color.fromRGBO(9, 101, 218, 0.25),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: applicationModel != null &&
                                  applicationModel!.esigneddocid.isNotEmpty,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      textStyle: const MaterialStatePropertyAll(
                                        TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1.3,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                        Color.fromRGBO(190, 215, 246, 1),
                                      ),
                                    ),
                                    onPressed: () async {
                                      application == null
                                          ? await getApplication()
                                          : null;
                                      try {
                                        downloadFile(
                                            application![0]
                                                .toString()
                                                .split(".")
                                                .first,
                                            application![1],
                                            application![0],
                                            context);
                                      } catch (e) {
                                        showSnackbar(
                                            context,
                                            "Some thing went wrong",
                                            Colors.red);
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'Download application PDF',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!,
                                        ),
                                        const SizedBox(width: 10.0),
                                        // const Icon(
                                        //   Icons.file_download_outlined,
                                        //   color: Colors.black,
                                        // ),
                                        RotatedBox(
                                          quarterTurns: 90,
                                          child: SvgPicture.asset(
                                            "assets/images/Download.svg",
                                            width: 15,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Email id : ${!isStatusLoaded && applicationModel != null ? applicationModel!.email.replaceAll("*", "x") : ''}",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "Application NO : ${!isStatusLoaded && applicationModel != null ? applicationModel!.applicationNo : ''}",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "Mobile number : ${!isStatusLoaded && applicationModel != null ? applicationModel!.mobil.replaceAll("*", "x") : ''}",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: "Application Status : ",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color)),
                                    TextSpan(
                                        text: !isStatusLoaded &&
                                                applicationModel != null
                                            ? applicationModel!
                                                .applicationStatus
                                            : '',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: applicationModel == null ||
                                                    applicationModel!
                                                        .applicationStatus
                                                        .isEmpty ||
                                                    !applicationModel!
                                                        .applicationStatus
                                                        .toLowerCase()
                                                        .contains("reject")
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color
                                                : const Color.fromRGBO(
                                                    217, 46, 11, 1)))
                                  ])),
                                  const SizedBox(height: 5.0),

                                  // details(
                                  //     context,
                                  //     'Email ID',
                                  //     !isStatusLoaded
                                  //         ? applicationModel!.email.replaceAll("*", "x")
                                  //         : ''),
                                  // const SizedBox(
                                  //   height: 10.0,
                                  // ),
                                  // details(
                                  //     context,
                                  //     'Mobile No.',
                                  //     !isStatusLoaded
                                  //         ? applicationModel!.mobil.replaceAll("*", "x")
                                  //         : ''),
                                  // const SizedBox(
                                  //   height: 10.0,
                                  // ),
                                  // details(
                                  //     context,
                                  //     'Application No.',
                                  //     !isStatusLoaded
                                  //         ? applicationModel!.applicationNo
                                  //         : ''),
                                  // const SizedBox(
                                  //   height: 10.0,
                                  // ),
                                  // details(
                                  //     context,
                                  //     'Application Status',
                                  //     !isStatusLoaded
                                  //         ? applicationModel!.applicationStatus
                                  //         : ''),
                                ]),
                            isStatusLoaded || applicationModel == null
                                ? SizedBox()
                                : applicationModel!.applicationStatus
                                        .toLowerCase()
                                        .contains("reject")
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Reason : ${!isStatusLoaded ? applicationModel!.rejectmsg : ""}",
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color),
                                          ),
                                          SizedBox(
                                            height: 15.0,
                                          ),
                                          Text(
                                            "Rejected Reason",
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color),
                                          ),
                                          // ...[1, 2, 3, 5, 6, 7, 7]
                                          //     .map((e) => Column(
                                          //           children: [
                                          //             Text("data"),
                                          //             SizedBox(),
                                          //             Text("$e")
                                          //           ],
                                          //         ))
                                          //     .toList()
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Container(
                                            // padding: EdgeInsets.all(10.0),
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)
                                                // border: Border(
                                                //   left: BorderSide(
                                                //       width: 1,
                                                //       color: Theme.of(context)
                                                //           .colorScheme
                                                //           .primary),
                                                //   right: BorderSide(
                                                //       width: 1,
                                                //       color: Theme.of(context)
                                                //           .colorScheme
                                                //           .primary),
                                                //   bottom: BorderSide(
                                                //       width: 1,
                                                //       color: Theme.of(context)
                                                //           .colorScheme
                                                //           .primary),
                                                // )
                                                ),
                                            child: Column(
                                              children: [
                                                ...keys.map((heading) {
                                                  return Container(
                                                    // padding:
                                                    //     EdgeInsets.all(10.0),
                                                    // decoration: BoxDecoration(
                                                    //     border: Border(
                                                    //         bottom: BorderSide(
                                                    //             width: 1,
                                                    //             color: Colors
                                                    //                 .black))),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              40.0,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5.0,
                                                                  right: 5.0,
                                                                  bottom: 3.0),
                                                          decoration: BoxDecoration(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      227,
                                                                      242,
                                                                      253,
                                                                      1),
                                                              borderRadius: keys
                                                                          .indexOf(
                                                                              heading) !=
                                                                      0
                                                                  ? BorderRadius
                                                                      .zero
                                                                  : BorderRadius.only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              6.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              6.0))
                                                              // border:
                                                              //     Border(
                                                              //   top: BorderSide(
                                                              //       width:
                                                              //           1,
                                                              //       color: Theme.of(context)
                                                              //           .colorScheme
                                                              //           .primary),
                                                              //   bottom: BorderSide(
                                                              //       width:
                                                              //           1,
                                                              //       color: Theme.of(context)
                                                              //           .colorScheme
                                                              //           .primary),
                                                              // )
                                                              ),
                                                          child: Text(
                                                            "$heading",
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                // color: Theme.of(
                                                                //         context)
                                                                //     .textTheme
                                                                //     .bodyLarge!
                                                                //     .color
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary),
                                                          ),
                                                        ),
                                                        SizedBox(height: 5.0),
                                                        Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ...applicationModel!
                                                                  .stagemsg[
                                                                      heading]
                                                                  .map((e) {
                                                                return Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                          width:
                                                                              15.0),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10.0),
                                                                        height:
                                                                            5.0,
                                                                        width:
                                                                            5.0,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.black,
                                                                            shape: BoxShape.circle),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              10.0),
                                                                      Expanded(
                                                                          child:
                                                                              Text("$e"))
                                                                    ],
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ]),
                                                        // ListView.builder(
                                                        //   itemCount: applicationModel!
                                                        //       .stagemsg[heading].length,
                                                        //   itemBuilder:
                                                        //       (context, index) {
                                                        //     return Row(
                                                        //       mainAxisAlignment:
                                                        //           MainAxisAlignment
                                                        //               .start,
                                                        //       crossAxisAlignment:
                                                        //           CrossAxisAlignment
                                                        //               .start,
                                                        //       children: [
                                                        //         SizedBox(width: 15.0),
                                                        //         Container(
                                                        //           height: 5.0,
                                                        //           width: 5.0,
                                                        //           decoration:
                                                        //               BoxDecoration(
                                                        //                   color: Colors
                                                        //                       .black,
                                                        //                   shape: BoxShape
                                                        //                       .circle),
                                                        //         ),
                                                        //         SizedBox(width: 10.0),
                                                        //         Text(applicationModel!
                                                        //                 .stagemsg[
                                                        //             heading][index])
                                                        //       ],
                                                        //     );
                                                        //   },
                                                        // )
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            ),
                                          )
                                          // Text(
                                          //   "heading",
                                          //   style: TextStyle(
                                          //       fontSize: 14.0,
                                          //       color: Theme.of(context)
                                          //           .textTheme
                                          //           .bodyLarge!
                                          //           .color),
                                          // ),
                                          // SizedBox(height: 5.0),
                                          // ListView.builder(
                                          //   itemBuilder: (context, index) {
                                          //     return Row(
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.start,
                                          //       crossAxisAlignment:
                                          //           CrossAxisAlignment.start,
                                          //       children: [
                                          //         SizedBox(width: 15.0),
                                          //         Container(
                                          //           height: 5.0,
                                          //           width: 5.0,
                                          //           decoration: BoxDecoration(
                                          //               color: Colors.black,
                                          //               shape: BoxShape.circle),
                                          //         )
                                          //       ],
                                          //     );
                                          //   },
                                          // )
                                        ],
                                      )
                                    : SizedBox(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Visibility(
                              visible: !isStatusLoaded &&
                                  applicationModel != null &&
                                  applicationModel!.applicationStatus
                                      .toString()
                                      .toLowerCase()
                                      .contains("reject"),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 60.0),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Color.fromRGBO(9, 101, 218, 1)),
                                    ),
                                    onPressed: () => Navigator.pushNamed(
                                        context, route.review),
                                    child: Center(
                                      child: Text(
                                        'Clear Your Rejection',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                fontSize: 17.0,
                                                height: 1,
                                                color: const Color.fromRGBO(
                                                    255, 255, 255, 1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        'Verification of the application could take up to 72 hours at the exchanges based on your KYC status',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(
                                fontSize: 15.0, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/endSymbol.png',
                            width: 65.0,
                            height: 65.0,
                          ),
                          const SizedBox(width: 5.0),
                          Flexible(
                            child: Text(
                              'You will receive 3 mails with your trading and Demat account Credentials Shortly',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),

                    // CustomButton(
                    //   onPressed: () {},
                    //   childText: 'Application Download',
                    // ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.020,
                    // ),
                    // Text(
                    //   'User Details',
                    //   textAlign: TextAlign.center,
                    //   style: Theme.of(context)
                    //       .textTheme
                    //       .bodyLarge!
                    //       .copyWith(fontWeight: FontWeight.w600, fontSize: 18.0),
                    // ),
                    // const SizedBox(
                    //   height: 10.0,
                    // ),

                    // Visibility(
                    //   visible: application != null,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       TextButton(
                    //           onPressed: () {},
                    //           child: Row(
                    //             children: [
                    //               Text(
                    //                 'Application Download',
                    //                 style: TextStyle(fontSize: 17.0),
                    //               ),
                    //               const SizedBox(width: 5.0),
                    //               Icon(Icons.download)
                    //             ],
                    //           )),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   width: double.infinity,
                    //   color: const Color.fromRGBO(9, 101, 218, 1),
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 20, vertical: 10.0),
                    //   child: Center(
                    //     child: Text(
                    //       'You can try our app with guest login in the mean time',
                    //       style: Theme.of(context)
                    //           .textTheme
                    //           .displayMedium!
                    //           .copyWith(
                    //               fontSize: 12.0,
                    //               height: 1,
                    //               color:
                    //                   const Color.fromRGBO(255, 255, 255, 1)),
                    //       textAlign: TextAlign.center,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20.0),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     ElevatedButton(
                    //       style: ButtonStyle(
                    //           backgroundColor: MaterialStatePropertyAll(
                    //               Color.fromRGBO(9, 101, 218, 1)),
                    //           minimumSize:
                    //               MaterialStatePropertyAll(Size(170, 45))),
                    //       onPressed: () {
                    //         launchUrlString(
                    //             // "market://details?id=com.noren.ftconline&hl=en&gl=US"
                    //             // "https://play.google.com/store/apps/details?id=com.noren.ftconline&hl=en&gl=US"
                    //             "http://onelink.to/amoflattrade");
                    //       },
                    //       child: Center(
                    //         child: Text(
                    //           'Guest Login',
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .bodyLarge!
                    //               .copyWith(
                    //                   fontSize: 17.0,
                    //                   height: 1,
                    //                   color: const Color.fromRGBO(
                    //                       255, 255, 255, 1)),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

Widget details(BuildContext context, String txt1, String txt2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          txt1,
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(fontSize: 12.0, height: 1),
        ),
      ),
      Text(
        ':',
        style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(fontSize: 12.0, height: 1),
        // textAlign: TextAlign.center,
      ),
      const SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: Text(
          txt2,
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(fontSize: 12.0, height: 1, fontWeight: FontWeight.w400),
        ),
      ),
    ],
  );
}
