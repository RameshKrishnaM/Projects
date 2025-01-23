import 'package:provider/provider.dart';

import '../Custom Widgets/alertbox.dart';
import '../Custom Widgets/stepwidget.dart';
import '../Screens/signup.dart';
import 'package:flutter/material.dart';
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
    //in this the address from the digilocker is set a new variable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      address = widget.address;
      allowModification =
          Provider.of<ProviderClass>(context, listen: false).allowModification;
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

  /* 
  Purpose: This method is used to get digilocker Status when it comes from url
  */

  getDigiLockerDetails() async {
    var uri = Uri.parse(widget.url ?? "");
    Map queryParameters = uri.queryParameters;
    String digiId = queryParameters["digi_id"] ?? "";
    String error = queryParameters["error"] ?? "";
    String errorDescription = queryParameters["error_description"] ?? "";

    if (error == "null") {
      getDigiInfo(digiId, widget.url);
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
              Text(errorDescription),
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

  /* 
  Purpose: This method is used to get the address from the digilocker using digiId 
  */

  getDigiInfo(digiId, url) async {
    loadingAlertBox(context);
    var response =
        await getDigiInfoAPI(context: context, digiId: digiId, url: url);
    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
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

  /* 
  Purpose: This method is used to insert the details from the Digilocker to the Db
  */

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

  /* 
  Purpose: This method is used to get the next route name from the Api
  */

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
        step: 1,
        title: "PAN & Address",
        title1: "Address Verification",
        subTitle: "Address Verification using Aadhaar  ",
        endPoint: route.address,
        buttonText: "Continue with Digilocker",
        scrollController: scrollController,
        buttonFunc: address == null ? null : () => postDigiInfo(),
        children: [
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
                              : const Color.fromRGBO(217, 217, 217, 1))),
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
                    ],
                  ),
                );
              }),
          const SizedBox(height: 40.0),
        ]);
  }
}
