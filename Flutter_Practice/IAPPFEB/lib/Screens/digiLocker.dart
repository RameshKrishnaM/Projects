import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../Custom Widgets/alertbox.dart';
import '../Custom%20Widgets/StepWidget.dart';
import '../Custom%20Widgets/custom_button.dart';
import '../Custom%20Widgets/custom_form_field.dart';
import '../Nodifier/nodifierCLass.dart';
import '../Screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../API call/api_call.dart';
import '../Route/route.dart' as route;
import '../provider/provider.dart';

class DigiLocker extends StatefulWidget {
  final Map? address;
  final String? url;
  const DigiLocker({super.key, this.address, this.url});

  @override
  State<DigiLocker> createState() => _DigiLockerState();
}

class _DigiLockerState extends State<DigiLocker> {
  FormValidateNodifier formValidateNodifier =
      FormValidateNodifier({"aadhaar": false});
  TextEditingController first4Digit = TextEditingController();
  TextEditingController middle4Digit = TextEditingController();
  TextEditingController last4Digit = TextEditingController();
  ScrollController scrollController = ScrollController();
  Map? address;
  String perAddress = "";
  String name = "";
  bool getInDigiLockerDB = false;
  bool allowModification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      address = widget.address;
      allowModification =
          Provider.of<Postmap>(context, listen: false).allowModification;
      if (address != null) {
        name = address!["name"] ?? "";
        perAddress = address!["peradrs1"] +
            ", " +
            address!["peradrs2"] +
            ", " +
            address!["peradrs3"] +
            ", " +
            address!["percity"] +
            ", " +
            address!["perpincode"] +
            ", " +
            address!["perstate"] +
            ", " +
            address!["percountry"];
        if (mounted) {
          setState(() {});
        }
      } else if (widget.url != null) {
        getDigiLockerDetails();
      }
    });
  }

  getDigiLockerDetails() async {
    // print("digi url ${widget.url}");

    var uri = Uri.parse(widget.url ?? "");
    Map queryParameters = uri.queryParameters;
    String digi_id = queryParameters["digi_id"] ?? "";
    String error = queryParameters["error"] ?? "";
    String error_description = queryParameters["error_description"] ?? "";
    // String error_description = queryParameters["Reg"] ?? "";

    // print(digi_id);
    // print(error);
    // print(error_description);

    if (error == "null") {
      // print(widget.url);
      getDigiInfo(digi_id, widget.url);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  Expanded(child: Text(textAlign: TextAlign.center, error)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.cancel),
                  )
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(error_description),
              const SizedBox(
                height: 10.0,
              ),
              const Text("Please try after some time"),
            ]),
          );
        },
      );
    }
  }

  getDigiInfo(digi_id, url) async {
    loadingAlertBox(context);
    var response =
        await getDigiInfoAPI(context: context, digiId: digi_id, url: url);
    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
      // print(response);
      address = response;
      name = response["name"];
      perAddress = perAddress = address!["peradrs1"] +
          ", " +
          address!["peradrs2"] +
          ", " +
          address!["peradrs3"] +
          ", " +
          address!["percity"] +
          ", " +
          address!["perpincode"] +
          ", " +
          address!["perstate"] +
          ", " +
          address!["percountry"];
      getInDigiLockerDB = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  postDigiInfo() async {
    loadingAlertBox(context);
    if (getInDigiLockerDB) {
      address!.remove("status");
      var response = await insertDigiInfoAPI(json: address, context: context);

      response != null
          ? getNextRoute(context)
          : mounted
              ? Navigator.pop(context)
              : null;
    } else {
      getNextRoute(context);
    }
  }

  getNextRoute(context) async {
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.address],
      "routeraction": "Next"
    });
    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepWidget(
        // endPoint: route.,
        step: 1,
        title: "PAN & Address",
        title1: "Address Verification",
        subTitle: "Address Verification using Aadhaar  ",
        endPoint: route.address,
        buttonText: "Continue with Digilocker",
        scrollController: scrollController,
        buttonFunc: address == null ? null : () => postDigiInfo(),
        children: [
          // ...getTitleANdSubTitleWidget("PAN & Address",
          //     "Address Verification using Aadhaar  ", context),
          const SizedBox(
            height: 30.0,
          ),
          ListenableBuilder(
              listenable: first4Digit,
              builder: (context, child) {
                return Container(
                  width: MediaQuery.of(context).size.width - 60.0,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          width: 1.3,
                          color: perAddress.isNotEmpty
                              ? Color.fromRGBO(50, 186, 124, 1)
                              : const Color.fromRGBO(217, 217, 217, 1)

                          // Theme.of(context).colorScheme.primary
                          )),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/digilocker1.jpeg",
                        width: 180.0,
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        "Flattrade Digilocker",
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 30.0),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                            color: Color.fromRGBO(111, 105, 105, 1)),
                      ),
                      const SizedBox(height: 10.0),
                      Visibility(
                        visible: perAddress.isNotEmpty,
                        child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(children: <InlineSpan>[
                              TextSpan(text: perAddress),
                              WidgetSpan(
                                  child: SizedBox(
                                width: 10.0,
                              )),
                              WidgetSpan(
                                  child: Visibility(
                                visible: allowModification,
                                child: GestureDetector(
                                  child: SvgPicture.asset(
                                    "assets/images/VectorEdit.svg",
                                    color: Colors.blue,
                                  ),
                                  onTap: () => openAlertBox(
                                    context: context,
                                    title: "Confirmation Required!",
                                    content:
                                        "If you edit the address, it will be a manual entry process. Would you like to continue?",
                                    button1color: Colors.green,
                                    button2color: Colors.red,
                                    onpressedButton1: () => Navigator.pushNamed(
                                        context, route.manualEntry,
                                        arguments: address!
                                          ..["soa"] = "Digilocker"),
                                  ),
                                ),
                              ))
                            ])),
                      ),
                      const SizedBox(height: 30.0),
                      // Text(
                      //     "Enter ADDHAAR number to continue with Digilocker",
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         color: Theme.of(context)
                      //             .textTheme
                      //             .bodyLarge!
                      //             .color)),
                      // const SizedBox(height: 10.0),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: CustomFormField(
                      //         contenModifytPadding: EdgeInsets.symmetric(
                      //             vertical: 0, horizontal: 2),
                      //         notSuffixIcon: true,
                      //         labelText: "aadhaar",
                      //         formValidateNodifier: formValidateNodifier,
                      //         controller: first4Digit,
                      //         inputFormatters: [
                      //           FilteringTextInputFormatter.digitsOnly,
                      //           LengthLimitingTextInputFormatter(4)
                      //         ],
                      //         keyboardType: TextInputType.phone,
                      //         textAlign: TextAlign.center,
                      //         validator: (value) {
                      //           if (value == null || value.isEmpty) {
                      //             return "please enter the aadhaar value";
                      //           }
                      //           if (value.length != 4) {
                      //             return "please enter valid aadhaar";
                      //           }
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //     const SizedBox(width: 15.0),
                      //     Expanded(
                      //       child: CustomFormField(
                      //         contenModifytPadding: EdgeInsets.symmetric(
                      //             vertical: 0, horizontal: 2),
                      //         notSuffixIcon: true,
                      //         labelText: "aadhaar",
                      //         formValidateNodifier: formValidateNodifier,
                      //         controller: middle4Digit,
                      //         inputFormatters: [
                      //           FilteringTextInputFormatter.digitsOnly,
                      //           LengthLimitingTextInputFormatter(4)
                      //         ],
                      //         keyboardType: TextInputType.phone,
                      //         textAlign: TextAlign.center,
                      //         validator: (value) {
                      //           if (value == null || value.isEmpty) {
                      //             return "please enter the aadhaar value";
                      //           }
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //     const SizedBox(width: 15.0),
                      //     Expanded(
                      //       child: CustomFormField(
                      //         contenModifytPadding: EdgeInsets.symmetric(
                      //             vertical: 0, horizontal: 2),
                      //         notSuffixIcon: true,
                      //         labelText: "aadhaar",
                      //         formValidateNodifier: formValidateNodifier,
                      //         controller: last4Digit,
                      //         inputFormatters: [
                      //           FilteringTextInputFormatter.digitsOnly,
                      //           LengthLimitingTextInputFormatter(4)
                      //         ],
                      //         keyboardType: TextInputType.phone,
                      //         textAlign: TextAlign.center,
                      //         validator: (value) {
                      //           if (value == null || value.isEmpty) {
                      //             return "please enter the aadhaar value";
                      //           }
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                );
              }),

          const SizedBox(height: 40.0),
        ]);
  }

  shoeBottomSheet(String name) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 60.0,
                // height: name.isEmpty ? 135.0 : null,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(237, 249, 254, 1),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Color.fromRGBO(0, 192, 100, 1),
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              InkWell(
                                child: SvgPicture.asset(
                                    "assets/images/VectorEdit.svg"),
                                onTap: () => Navigator.pushNamed(
                                    context, route.manualEntry,
                                    arguments: widget.address),
                              )
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                              "Using User Details we Securely accessed your details from the Income Tax Department"),
                          const SizedBox(height: 20.0),
                          RichText(
                              text: TextSpan(children: [
                            const WidgetSpan(child: Text("Not you? ")),
                            WidgetSpan(
                                child: InkWell(
                              child: Text(
                                're enter PAN',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ))
                          ]))
                        ])),
              ),
              const SizedBox(height: 20.0),
              CustomButton(
                  buttonText: "Continue",
                  buttonFunc: () {
                    // Navigator.pop(context);
                    // shoeBottomSheet("");
                    address != null ? postDigiInfo() : null;
                  })
            ],
          ),
        );
      },
    );
  }
}
