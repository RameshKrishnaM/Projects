import 'dart:io';

import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/error_message.dart';
import 'package:ekyc/Custom%20Widgets/scrollable_widget.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../API call/api_call.dart';
import '../Custom%20Widgets/custom_button.dart';
import '../Route/route.dart' as route;

class StepWidget extends StatefulWidget {
  final String? endPoint;
  final int? step;
  final String title;
  final String? title1;
  final String subTitle;
  final bool? backFunc;
  final bool? dowanArrow; //not in use
  final String? buttonText;
  final buttonFunc;
  final arrowFunc;
  final bool? isReviewPage;
  final bool? notShowBackButton;

  final List<Widget> children;
  final ScrollController scrollController;

  const StepWidget(
      {super.key,
      this.step,
      required this.title,
      required this.subTitle,
      required this.children,
      this.title1,
      this.endPoint,
      required this.scrollController,
      this.backFunc,
      this.buttonText,
      this.buttonFunc,
      this.dowanArrow,
      this.arrowFunc,
      this.isReviewPage,
      this.notShowBackButton});

  @override
  State<StepWidget> createState() => _StepWidgetState();
}

class _StepWidgetState extends State<StepWidget> {
  ScrollController controller = ScrollController();
  String? errmsg;
  double height = 0;
  @override
  void initState() {
    super.initState();
    widget.isReviewPage == true ? controller = widget.scrollController : null;
    elevation();
    controller.addListener(() {
      double position =
          controller.position.maxScrollExtent - controller.position.pixels;
      height = position > 12
          ? 8
          : position.isNegative
              ? 0
              : position;

      setState(() {});
    });
  }

  /* 
  Purpose: This method is used to elevate the button when it is not in the last position
  */

  elevation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 250));
      double position =
          controller.position.maxScrollExtent - controller.position.pixels;
      height = position > 12
          ? 8
          : position.isNegative
              ? 0
              : position;
      height = widget.isReviewPage == true ? 12.0 : 0;
      setState(() {});
    });
  }

  /* 
  Purpose: This method is used to get the previous page name from the api 
  */

  getPrevoiusRoute(context) async {
    if (widget.endPoint == route.address || widget.endPoint == route.panCard) {
      openAlertBox(
          context: context,
          content: "Do you want to Exit?",
          onpressedButton1: () => exit(0));
      return;
    } else {
      loadingAlertBox(context);
      var response = await getRouteNameInAPI(context: context, data: {
        "routername": route.routeNames[widget.endPoint],
        "routeraction": "PREVIOUS"
      });

      if (mounted) {
        Navigator.pop(context);
      }

      if (response != null) {
        Navigator.pushNamedAndRemoveUntil(
            context, response["endpoint"], (route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PopScope(
        canPop: widget.endPoint == null &&
            widget.backFunc != true &&
            widget.notShowBackButton != true,
        onPopInvoked: (didPop) {
          if (widget.backFunc == true) {
            // when the back button is not shown this alert box will open
            openAlertBox(
                context: context,
                content: "Are you want to go back?",
                onpressedButton1: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, route.nominee, arguments: true);
                });
            return;
          }
          ProviderClass provider =
              Provider.of<ProviderClass>(context, listen: false);
          if (provider.isEditPage) {
            provider.changeIsEditPage(false);
            Navigator.pushNamedAndRemoveUntil(
                context, route.review, (route) => route.isFirst);
            return;
          }
          if (widget.notShowBackButton == true) {
            openAlertBox(
                context: context,
                content: "Do you want to Exit?",
                onpressedButton1: () => exit(0));
            return;
          }
          !didPop ? getPrevoiusRoute(context) : null;
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/background_image.png"))),
            child: SingleChildScrollView(
              controller:
                  widget.isReviewPage != true ? widget.scrollController : null,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ScrollableWidget(
                          controller: widget.scrollController,
                          child: Stack(
                            children: [
                              ListView(
                                controller: widget.isReviewPage == true
                                    ? widget.scrollController
                                    : controller,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 15.0, top: 15.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        widget.step == 1 ||
                                                (widget.notShowBackButton ??
                                                    false)
                                            ? const SizedBox(
                                                width: 15.0,
                                              )
                                            : GestureDetector(
                                                onTap: widget.backFunc == true
                                                    ? () => openAlertBox(
                                                          context: context,
                                                          content:
                                                              "Are you want to go back ?",
                                                          onpressedButton1: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pushNamed(
                                                                context,
                                                                route.nominee,
                                                                arguments:
                                                                    true);
                                                          },
                                                        )
                                                    : Provider.of<ProviderClass>(
                                                                context,
                                                                listen: false)
                                                            .isEditPage
                                                        ? () {
                                                            Provider.of<ProviderClass>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .changeIsEditPage(
                                                                    false);
                                                            Navigator.pushNamedAndRemoveUntil(
                                                                context,
                                                                route.review,
                                                                (route) => route
                                                                    .isFirst);
                                                          }
                                                        : widget.endPoint ==
                                                                    null &&
                                                                widget.backFunc !=
                                                                    true
                                                            ? () =>
                                                                Navigator.pop(
                                                                    context)
                                                            : () =>
                                                                getPrevoiusRoute(
                                                                    context),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromRGBO(
                                                              9, 101, 218, 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                          width: 1.0,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color!)),
                                                  child: Row(children: [
                                                    const Icon(
                                                      CupertinoIcons
                                                          .arrow_uturn_left,
                                                      size: 12.0,
                                                    ),
                                                    const SizedBox(width: 2.0),
                                                    Text(
                                                      "Back",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                              fontSize: 12.0),
                                                    )
                                                  ]),
                                                ),
                                              ),
                                        const SizedBox(width: 15.0),
                                        Flexible(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5.0,
                                                      vertical: 2.0),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      border: Border.all(
                                                          color: const Color
                                                              .fromRGBO(
                                                              34, 147, 52, 1))),
                                                  child: Text(
                                                    widget.title,
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                          color: const Color
                                                              .fromRGBO(
                                                              50, 169, 220, 1),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5.0,
                                              ),
                                              Text(widget.step != null
                                                  ? "Step ${widget.step}/6"
                                                  : ""),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        GestureDetector(
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              child: SvgPicture.asset(
                                                "assets/images/person.svg",
                                                height: 22.0,
                                                width: 22.0,
                                              )),
                                          onTap: () => helpBottomSheet(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        // It is not applicable for review page
                                        widget.endPoint != route.review
                                            ? ErrorMessageContainer(
                                                message:
                                                    Provider.of<ProviderClass>(
                                                            context)
                                                        .errMsg,
                                              )
                                            : const SizedBox(),
                                        Text(
                                          widget.title1 ?? widget.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(widget.subTitle),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        ...widget.children,
                                        const SizedBox(height: 20.0)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                        Colors.grey.withOpacity(0),
                                        Colors.grey.withOpacity(0.15),
                                      ])),
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      CustomButton(
                          buttonText: widget.buttonText,
                          buttonFunc: widget.buttonFunc),
                      const SizedBox(height: 30.0)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

DateTime? date;

/* 
  Purpose: This method is used to show the bottom sheet for the log out button
  */

helpBottomSheet(context) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Facing Difficulties?",
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(106, 100, 100, 1)),
            ),
            const SizedBox(height: 10.0),
            ListTile(
              title: const Text("Need Assistance?",
                  style: TextStyle(
                      fontSize: 15.0, color: Color.fromRGBO(106, 100, 100, 1))),
              subtitle: RichText(
                  text: TextSpan(
                      style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(112, 112, 112, 1)),
                      children: [
                    const TextSpan(
                        text: "Call ", style: TextStyle(fontSize: 13.0)),
                    TextSpan(
                        text: "044-45609696 ",
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 13.0),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(Uri(
                                scheme: 'tel',
                                path: "044-45609696",
                              ))),
                    const TextSpan(text: "/ "),
                    TextSpan(
                        text: "044-61329696 ",
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 13.0),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(Uri(
                                scheme: 'tel',
                                path: "044-61329696",
                              ))),
                  ])),
              leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [SvgPicture.asset("assets/images/assistance.svg")]),
            ),
            const SizedBox(height: 30.0),
            CustomButton(
                buttonText: "Log out",
                color: const Color.fromRGBO(248, 76, 76, 1),
                buttonFunc: () => logout(context)),
            const SizedBox(height: 30.0)
          ],
        ),
      );
    },
  );
}
