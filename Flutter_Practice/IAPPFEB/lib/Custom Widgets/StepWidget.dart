import 'dart:io';

import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/error_message.dart';
import 'package:ekyc/Custom%20Widgets/scrollable_widget.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Custom%20Widgets/custom_button.dart';
import '../Custom%20Widgets/dotted_line.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../API call/api_call.dart';
import '../Route/route.dart' as route;

class StepWidget extends StatefulWidget {
  final String? endPoint;
  final int? step;
  final String title;
  final String? title1;
  final String subTitle;
  final bool? backFunc;
  final bool? dowanArrow;
  // final bool? titleNotShow;
  final String? buttonText;
  final buttonFunc;
  final arrowFunc;
  final bool? isReviewPage;
  final bool? notShowBackButton;

  // final bool? backButtonShow;
  // final bool resizeToAvoidBottomInset;
  final List<Widget> children;
  final ScrollController scrollController;

  const StepWidget(
      {super.key,
      this.step,
      required this.title,
      required this.subTitle,
      // this.resizeToAvoidBottomInset = false,
      required this.children,
      this.title1,
      this.endPoint,
      required this.scrollController,
      this.backFunc,
      // this.titleNotShow,
      this.buttonText,
      this.buttonFunc,
      this.dowanArrow,
      this.arrowFunc,
      this.isReviewPage,
      this.notShowBackButton
      // this.backButtonShow
      });

  @override
  State<StepWidget> createState() => _StepWidgetState();
}

class _StepWidgetState extends State<StepWidget> {
  ScrollController controller = ScrollController();
  String? errmsg;
  double height = 0;
  // bool downArrowVisible = false;
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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.animateTo(1,
    //       duration: Duration(milliseconds: 100), curve: Curves.linear);
    // });
  }

  // @override
  // didChangeDependencies() {
  //   super.didChangeDependencies();
  //   print("lksflkjedhjfehjefg");
  // }

  elevation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 250));
      print("max ${controller.position.maxScrollExtent}");
      print("statrt ${controller.position.pixels}");
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

  // getErrorMsg() async {
  //   SharedPreferences sref = await SharedPreferences.getInstance();
  //   errmsg=sref.get
  // }

  getPrevoiusRoute(context) async {
    if (widget.endPoint == route.address || widget.endPoint == route.panCard) {
      // loadingAlertBox(context);
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
        // if (response["endpoint"] == route.signup ||
        //     response["endpoint"] == route.panCard) {
        //   openAlertBox(
        //       context: context,
        //       content: "Do you want to Exit?",
        //       onpressedButton1: () => exit(0));
        //   return;
        // }
        //else {
        // var response = await getRouteNameInAPI(context: context, data: {
        //   "routername": route.routeNames[widget.endPoint],
        //   "routeraction": "CURRENT"
        // });

        // if (mounted) {
        //   Navigator.pop(context);
        // }

        // if (response != null) {
        //   if (response["endpoint"] == route.signup ||
        //       response["endpoint"] == route.panCard) {
        //     openAlertBox(
        //         context: context,
        //         content: "Do you want to Exit?",
        //         onpressedButton1: () => exit(0));
        //     return;
        //   }

        // if(response[])
        // print(response["endpoint"]);
        Navigator.pushNamedAndRemoveUntil(
            context, response["endpoint"], (route) => route.isFirst);
        // Navigator.push(context, response["endpoint"]);
        // }
        // }
        // Navigator.pushNamedAndRemoveUntil(
        //     context, response["endpoint"], (route) => route.isFirst);
        // Navigator.push(context, response["endpoint"]);
      }
    }
  }

  // getCurrentRoute(context) async {
  //   loadingAlertBox(context);

  //   var response = await getRouteNameInAPI(context: context, data: {
  //     "routername": route.routeNames[widget.endPoint],
  //     "routeraction": "CURRENT"
  //   });

  //   if (mounted) {
  //     Navigator.pop(context);
  //   }

  //   if (response != null) {
  //     if (response["endpoint"] == route.signup ||
  //         response["endpoint"] == route.panCard) {
  //       openAlertBox(
  //           context: context,
  //           content: "Do you want to Exit?",
  //           onpressedButton1: () => exit(0));
  //       return;
  //     }
  //     // if(response[])
  //     Navigator.pushNamedAndRemoveUntil(
  //         context, response["endpoint"], (route) => route.isFirst);
  //     // Navigator.push(context, response["endpoint"]);
  //   }
  // }

  // openAlertBox(context) {
  //   print("object");
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(
  //           "Are you want to go back ?",
  //           style: Theme.of(context).textTheme.displayMedium,
  //         ),
  //         actions: [
  //           SizedBox(
  //             height: 30.0,
  //             child: ElevatedButton(
  //                 style: ButtonStyle(
  //                   elevation: const MaterialStatePropertyAll(0),
  //                   shape: MaterialStatePropertyAll(RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(6))),
  //                 ),
  //                 onPressed: () {
  //   Navigator.pop(context);
  //   Navigator.pushNamedAndRemoveUntil(
  //       context, route.nominee, (route) => false,
  //       arguments: true);
  // },
  //                 child: const Text("Yes")),
  //           ),
  //           SizedBox(
  //             height: 30.0,
  //             child: ElevatedButton(
  //                 style: ButtonStyle(
  //                   elevation: const MaterialStatePropertyAll(0),
  //                   shape: MaterialStatePropertyAll(RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(6))),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("No")),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PopScope(
        canPop: widget.endPoint == null &&
            widget.backFunc != true &&
            widget.notShowBackButton != true
        // && backFunc != null,
        ,
        onPopInvoked: (didPop) {
          if (widget.backFunc == true) {
            openAlertBox(
                context: context,
                content: "Are you want to go back?",
                onpressedButton1: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, route.nominee,
                      //  (route) => false,
                      arguments: true);
                });
            return;
          }
          Postmap provider = Provider.of<Postmap>(context, listen: false);
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
                              // CustomScrollView(
                              //   controller: widget.isReviewPage == true
                              //       ? widget.scrollController
                              //       : controller,
                              //   slivers: [
                              //     SliverAppBar(
                              //       automaticallyImplyLeading: false,
                              //       backgroundColor: Colors.transparent,
                              //       elevation: 8,
                              //       shadowColor: Colors.grey.withOpacity(0.15),
                              //       // title: Text("Tilte"),
                              //       // toolbarHeight: 70,
                              //       // collapsedHeight: 60.0,
                              //       // expandedHeight: 150.0,
                              //       // stretch: true,
                              //       floating: true,
                              //       flexibleSpace: Container(
                              //         height: 100.0,
                              //         decoration: const BoxDecoration(
                              //             image: DecorationImage(
                              //                 fit: BoxFit.cover,
                              //                 image: AssetImage(
                              //                     "assets/images/background_image_appBar.png"))),
                              //         padding: const EdgeInsets.only(
                              //             left: 30.0,
                              //             right: 15.0,
                              //             top: 15.0,
                              //             bottom: 5.0),
                              //         child: Row(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             // SizedBox(
                              //             //   height: 20.0,
                              //             //   width: 20.0,
                              //             // ),
                              //             widget.step == 1
                              //                 ? SizedBox(
                              //                     width: 15.0,
                              //                   )
                              //                 : GestureDetector(
                              //                     // padding: const EdgeInsets.only(top: 28.0),
                              //                     child: Container(
                              //                       padding: EdgeInsets.all(4.0),
                              //                       decoration: BoxDecoration(
                              //                           color: Color.fromRGBO(
                              //                               9, 101, 218, 0.1),
                              //                           borderRadius:
                              //                               BorderRadius.circular(
                              //                                   8.0),
                              //                           border: Border.all(
                              //                               width: 1.0,
                              //                               color:
                              //                                   Theme.of(context)
                              //                                       .textTheme
                              //                                       .bodyLarge!
                              //                                       .color!)),
                              //                       child: Row(children: [
                              //                         Icon(
                              //                           CupertinoIcons
                              //                               .arrow_uturn_left,
                              //                           size: 12.0,
                              //                         ),
                              //                         const SizedBox(width: 2.0),
                              //                         Text(
                              //                           "Back",
                              //                           style: Theme.of(context)
                              //                               .textTheme
                              //                               .bodyLarge!
                              //                               .copyWith(
                              //                                   fontSize: 12.0),
                              //                         )
                              //                       ]),
                              //                     ),
                              //                     onTap: () => widget.endPoint ==
                              //                                 null &&
                              //                             widget.backFunc != true
                              //                         ? Navigator.pop(context)
                              //                         : widget.backFunc == true
                              //                             ? openAlertBox(
                              //                                 context: context,
                              //                                 content:
                              //                                     "Are you want to go back ?",
                              //                                 onpressedButton1:
                              //                                     () {
                              //                                   Navigator.pop(
                              //                                       context);
                              //                                   Navigator.pushNamed(
                              //                                       context,
                              //                                       route.nominee,
                              //                                       //  (route) => false,
                              //                                       arguments:
                              //                                           true);
                              //                                 },
                              //                               )
                              //                             : getPrevoiusRoute(
                              //                                 context),
                              //                   ),
                              //             const SizedBox(width: 15.0),
                              //             Flexible(
                              //               //padding: const EdgeInsets.only(top: 27.0),
                              //               child: Row(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment.center,
                              //                 children: [
                              //                   Flexible(
                              //                     child: Container(
                              //                       padding: const EdgeInsets
                              //                           .symmetric(
                              //                           horizontal: 5.0,
                              //                           vertical: 2.0),
                              //                       decoration: BoxDecoration(
                              //                           borderRadius:
                              //                               BorderRadius.circular(
                              //                                   5.0),
                              //                           border: Border.all(
                              //                               color: const Color
                              //                                   .fromRGBO(
                              //                                   34, 147, 52, 1))),
                              //                       child: Text(
                              //                         widget.title,
                              //                         textAlign: TextAlign.center,
                              //                         style: Theme.of(context)
                              //                             .textTheme
                              //                             .bodyLarge!
                              //                             .copyWith(
                              //                               color: const Color
                              //                                   .fromRGBO(
                              //                                   50, 169, 220, 1),
                              //                             ),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   const SizedBox(
                              //                     width: 5.0,
                              //                   ),
                              //                   Text(widget.step != null
                              //                       ? "Step ${widget.step}/6"
                              //                       : ""),
                              //                 ],
                              //               ),
                              //             ),

                              //             const SizedBox(
                              //               width: 10.0,
                              //             ),
                              //             //padding: const EdgeInsets.only(top: 27.0),
                              //             GestureDetector(
                              //               child: Container(
                              //                   // width: 30.0,
                              //                   // height: 30.0,
                              //                   // alignment: Alignment.center,
                              //                   padding: const EdgeInsets.all(5),
                              //                   decoration: BoxDecoration(
                              //                       color: Theme.of(context)
                              //                           .colorScheme
                              //                           .primary,
                              //                       borderRadius:
                              //                           BorderRadius.circular(
                              //                               20.0)),
                              //                   child:
                              //                       //  Text(
                              //                       //   "i",
                              //                       //   style: TextStyle(
                              //                       //       height: 1,
                              //                       //       fontWeight: FontWeight.w900,
                              //                       //       fontSize: 18.0,
                              //                       //       color: Colors.white),
                              //                       // )
                              //                       //     const Icon(
                              //                       //   Icons.power_settings_new,
                              //                       //   color: Colors.white,
                              //                       //   size: 20.0,
                              //                       // )
                              //                       SvgPicture.asset(
                              //                     "assets/images/person.svg",
                              //                     height: 22.0,
                              //                     width: 22.0,
                              //                   )),
                              //               onTap: () =>
                              //                   // openAlertBox(
                              //                   //     context: context,
                              //                   //     content: "Do you want to logout?",
                              //                   //     onpressedButton1: () => logout(context)),
                              //                   helpBottomSheet(context),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //     SliverPadding(
                              //       padding:
                              //           EdgeInsets.symmetric(horizontal: 30.0),
                              //       sliver: SliverList(
                              //           delegate: SliverChildListDelegate([
                              //         const SizedBox(
                              //           height: 10.0,
                              //         ),
                              //         Text(
                              //           widget.title1 ?? widget.title,
                              //           style:
                              //               Theme.of(context).textTheme.bodyLarge,
                              //         ),
                              //         const SizedBox(
                              //           height: 10.0,
                              //         ),
                              //         Text(widget.subTitle),
                              //         const SizedBox(
                              //           height: 20.0,
                              //         ),
                              //         ...widget.children,
                              //         const SizedBox(height: 20.0)
                              //       ])),
                              //     )
                              //   ],
                              // ),
                              // *******************88
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
                                        // SizedBox(
                                        //   height: 20.0,
                                        //   width: 20.0,
                                        // ),
                                        widget.step == 1 ||
                                                (widget.notShowBackButton ??
                                                    false)
                                            ? const SizedBox(
                                                width: 15.0,
                                              )
                                            : GestureDetector(
                                                // padding: const EdgeInsets.only(top: 28.0),
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
                                                                //  (route) => false,
                                                                arguments:
                                                                    true);
                                                          },
                                                        )
                                                    : Provider.of<Postmap>(
                                                                context,
                                                                listen: false)
                                                            .isEditPage
                                                        ? () {
                                                            print(
                                                                "cond ${Provider.of<Postmap>(context, listen: false)}");
                                                            Provider.of<Postmap>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .changeIsEditPage(
                                                                    false);
                                                            print(
                                                                "cond ${Provider.of<Postmap>(context, listen: false)}");
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
                                              ),
                                        const SizedBox(width: 15.0),
                                        Flexible(
                                          //padding: const EdgeInsets.only(top: 27.0),
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
                                        //padding: const EdgeInsets.only(top: 27.0),
                                        GestureDetector(
                                          child: Container(
                                              // width: 30.0,
                                              // height: 30.0,
                                              // alignment: Alignment.center,
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              child:
                                                  //  Text(
                                                  //   "i",
                                                  //   style: TextStyle(
                                                  //       height: 1,
                                                  //       fontWeight: FontWeight.w900,
                                                  //       fontSize: 18.0,
                                                  //       color: Colors.white),
                                                  // )
                                                  //     const Icon(
                                                  //   Icons.power_settings_new,
                                                  //   color: Colors.white,
                                                  //   size: 20.0,
                                                  // )
                                                  SvgPicture.asset(
                                                "assets/images/person.svg",
                                                height: 22.0,
                                                width: 22.0,
                                              )),
                                          onTap: () =>
                                              // openAlertBox(
                                              //     context: context,
                                              //     content: "Do you want to logout?",
                                              //     onpressedButton1: () => logout(context)),
                                              helpBottomSheet(context),
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
                                        widget.endPoint != route.review
                                            ? ErrorMessageContainer(
                                                message: Provider.of<Postmap>(
                                                        context)
                                                    .errMsg,
                                              )
                                            : const SizedBox(),
                                        // Container(
                                        //     width: MediaQuery.of(context)
                                        //             .size
                                        //             .width -
                                        //         60.0,
                                        //     padding: EdgeInsets.all(5.0),
                                        //     decoration: BoxDecoration(
                                        //         color: Color.fromARGB(
                                        //             255, 240, 81, 70),
                                        //         borderRadius:
                                        //             BorderRadius.all(
                                        //                 Radius.circular(
                                        //                     6.0))),
                                        //     child: Text(
                                        //       "Your pan number is miss match",
                                        //       style: TextStyle(
                                        //           color: Colors.white,
                                        //           fontWeight: FontWeight.bold,
                                        //           fontSize: 17.0),
                                        //     ),
                                        //   ),

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
                              // widget.dowanArrow == true
                              //     ? Padding(
                              //         padding: const EdgeInsets.only(right: 7.0),
                              //         child: GestureDetector(
                              //             child: Container(
                              //               height: MediaQuery.of(context)
                              //                   .size
                              //                   .height,
                              //               alignment: Alignment.bottomRight,
                              //               child: Container(
                              //                 padding: const EdgeInsets.all(10.0),
                              //                 decoration: BoxDecoration(
                              //                     color: Colors.blue
                              //                         .withOpacity(0.3),
                              //                     shape: BoxShape.circle),
                              //                 child: Stack(
                              //                   children: [
                              //                     SvgPicture.asset(
                              //                       'assets/images/arrowdown.svg',
                              //                       width: 7.0,
                              //                       height: 7.0,
                              //                     ),
                              //                     Padding(
                              //                       padding:
                              //                           const EdgeInsets.only(
                              //                               top: 5.0),
                              //                       child: SvgPicture.asset(
                              //                         'assets/images/arrowdown.svg',
                              //                         width: 7.0,
                              //                         height: 7.0,
                              //                       ),
                              //                     )
                              //                   ],
                              //                 ),
                              //               ),
                              //             ),
                              //             onTap: () {
                              //               widget.scrollController.animateTo(
                              //                 widget.scrollController.position
                              //                     .maxScrollExtent,
                              //                 duration: const Duration(
                              //                     milliseconds: 250),
                              //                 curve: Curves.linear,
                              //               );
                              //               // print(
                              //               //     widget.scrollController.position);
                              //             }),
                              //       )
                              //     : const SizedBox()
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      CustomButton(
                          buttonText: widget.buttonText,
                          buttonFunc: widget.buttonFunc),
                      const SizedBox(height: 15.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 50),
      //   child: GestureDetector(
      //     child: Container(
      //         width: 30.0,
      //         height: 30.0,
      //         alignment: Alignment.center,
      //         padding: const EdgeInsets.all(5),
      //         decoration: BoxDecoration(
      //           color: Theme.of(context).colorScheme.primary,
      //           borderRadius: BorderRadius.circular(20.0),
      //           // boxShadow: [
      //           //   BoxShadow(
      //           //       color: Color.fromARGB(8, 80, 79, 79),
      //           //       blurRadius: 50,
      //           //       spreadRadius: 50,
      //           //       offset: Offset(0, 5),
      //           //       blurStyle: BlurStyle.outer)
      //           // ]
      //         ),
      //         child: Text(
      //           "?",
      //           style: TextStyle(
      //               height: 1,
      //               fontWeight: FontWeight.w900,
      //               fontSize: 18.0,
      //               color: Colors.white),
      //         )
      //         //     Icon(
      //         //   Icons.help_outline,
      //         //   color: Colors.white,
      //         //   size: 20.0,
      //         // )
      //         //  SvgPicture.asset(
      //         //   "assets/images/person.svg",
      //         //   height: 22.0,
      //         //   width: 22.0,
      //         // )
      //         ),
      //     onTap: () => helpBottomSheet(context),
      //   ),
      // ),
    );
  }
}

DateTime? date;

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
              //  const Text(
              //   "call 044-45609696 / 044-61329696",
              // style: TextStyle(
              //     fontSize: 10.0,
              //     fontWeight: FontWeight.w500,
              //     color: Color.fromRGBO(112, 112, 112, 1)),
              // ),
              leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [SvgPicture.asset("assets/images/assistance.svg")]),
            ),
            // const DottedLine(
            //   color: Color.fromRGBO(0, 0, 0, 0.5),
            //   isSmall: true,
            // ),
            // const SizedBox(height: 10.0),
            // GestureDetector(
            //   child: Row(
            //     children: [
            //       const SizedBox(width: 12.0),
            //       SvgPicture.asset("assets/images/tutorial.svg"),
            //       const SizedBox(width: 25.0),
            //       const Text("Watch Tutorial",
            //           style: TextStyle(
            //               fontSize: 15.0,
            //               color: Color.fromRGBO(106, 100, 100, 1)))
            //     ],
            //   ),
            //   onTap: () async {
            //     // String iosUrl =
            //     //     'youtube://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw';
            //     // String url =
            //     //     'https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw';
            //     // // https: //www.youtube.com/watch?v=VD7UKzXblJU
            //     // if (Platform.isIOS) {
            //     //   if (await canLaunchUrl(Uri.parse(iosUrl))) {
            //     //     await launchUrl(
            //     //       Uri.parse(iosUrl),
            //     //     );
            //     //   } else {
            //     //     if (await canLaunchUrl(Uri.parse(url))) {
            //     //       await launchUrl(Uri.parse(url));
            //     //     } else {
            //     //       throw 'Could not launch $url';
            //     //     }
            //     //   }
            //     // } else {
            //     //   if (await canLaunchUrl(Uri.parse(url))) {
            //     //     await launchUrl(Uri.parse(url));
            //     //   } else {
            //     //     throw 'Could not launch $url';
            //     //   }
            //     // }
            //   },
            // ),
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

getTitleANdSubTitleWidget(String title, String subTitle, context) {
  return [
    const SizedBox(
      height: 20.0,
    ),
    Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge,
    ),
    const SizedBox(
      height: 10.0,
    ),
    Text(subTitle),
    const SizedBox(
      height: 20.0,
    ),
  ];
}
