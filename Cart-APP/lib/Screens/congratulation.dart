import 'dart:convert';
import 'dart:io';

import 'package:flutter_svg/svg.dart';

import '../API%20call/api_call.dart';
import '../Custom Widgets/alertbox.dart';
import '../Screens/signup.dart';
import '../Service/download_file.dart';
import 'package:flutter/material.dart';
import '../Custom Widgets/customstacks.dart';
import '../Custom Widgets/custom_snackbar.dart';
import '../Model/application_status.dart';
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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  List? application;

  /* 
  Purpose: This method is used to get application .
  */

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

  /* 
  Purpose: This method is used to get the form status from the api.
  */

  fetchData() async {
    loadingAlertBox(context);
    var response = await getFormStatus(context: context);
    if (response != null) {
      applicationModel = applicationModelFromJson(jsonEncode(response));
      keys = applicationModel!.stagemsg.keys.toList();
      isStatusLoaded = false;
    }
    if (mounted) {
      setState(() {});
      Navigator.pop(context);
    }
  }

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
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Container(
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            child: Column(
                                              children: [
                                                ...keys.map((heading) {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
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
                                                            color:
                                                                Color.fromRGBO(
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
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            6.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            6.0))),
                                                        child: Text(
                                                          "$heading",
                                                          style: TextStyle(
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
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
                                                                padding:
                                                                    const EdgeInsets
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
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 10.0),
                                                                      height:
                                                                          5.0,
                                                                      width:
                                                                          5.0,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .black,
                                                                          shape:
                                                                              BoxShape.circle),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            10.0),
                                                                    Expanded(
                                                                        child: Text(
                                                                            "$e"))
                                                                  ],
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ]),
                                                    ],
                                                  );
                                                }),
                                              ],
                                            ),
                                          )
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
