import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../API call/api_call.dart';
import '../Custom Widgets/custom_drop_down.dart';
import '../Custom Widgets/custom_radio_button.dart';
import '../Custom Widgets/custom_snackbar.dart';
import '../Custom Widgets/custom_tile.dart';
import '../Custom Widgets/infoalertbox.dart';
import '../Custom Widgets/risk_diskclosure_alertbox.dart';
import '../Custom Widgets/stepwidget.dart';
import '../Nodifier/nodifierclass.dart';
import '../Route/route.dart' as route;
import '../provider/provider.dart';
import '../shared_preferences/shared_preference_func.dart';

class SegmentSelection extends StatefulWidget {
  const SegmentSelection({super.key});

  @override
  State<SegmentSelection> createState() => _SegmentSelectionState();
}

class _SegmentSelectionState extends State<SegmentSelection> {
  TextEditingController dpSchemeController = TextEditingController(text: "");
  TextEditingController settleOfFCSPLController =
      TextEditingController(text: "");
  FormValidateNodifier formValidateNodifierDpScheme =
      FormValidateNodifier({'Select DP Scheme': false});
  List demantDropDownValues = [];
  List demantDropDownOptions = [];
  List settleOfFCSPLDropDownValues = [];
  List settleOfFCSPLDropDownOptions = [];
  String? disValue;
  String? eDisValue;
  List titles = [];
  List subTitles = [];
  List selectedTile = [];
  List userSelects = [];
  List brokerageHeading = [];
  List brokerageData = [];
  Map bankData = {};
  bool isLoading = true;
  String tariffDetailsUrl = "";
  Map serviceData = {};
  Map oldDemantServ = {};
  bool isEdit = true;
  String disDescription = "";
  String edisDescription = "";
  String aggregatorDocID = "";
  String aggregatorConsentID = "";
  WebViewController con1 = WebViewController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  /* 
  Purpose: This method is used to get te initial Data for segment screen and map with the required variables.
*/

  fetchData() async {
    loadingAlertBox(context);
    try {
      var dropDownResponse =
          await getDropDownValues(context: context, code: "DematData");

      if (dropDownResponse != null) {
        demantDropDownValues = dropDownResponse['lookupvaluearr'] ?? [];
        int dpschemeIndex = demantDropDownValues
            .indexWhere((element) => element["code"] == "341");
        dpSchemeController.text = dpschemeIndex != -1
            ? demantDropDownValues[dpschemeIndex]["description"]
            : "";

        demantDropDownOptions.addAll(demantDropDownValues
            .map((element) => element['description'])
            .toList());
      }
      var dropDown2Response =
          await getDropDownValues(context: context, code: "Settlement_Type");
      if (dropDown2Response != null) {
        settleOfFCSPLDropDownValues = dropDown2Response['lookupvaluearr'] ?? [];
        int dpschemeIndex = settleOfFCSPLDropDownValues
            .indexWhere((element) => element["code"] == "1");

        settleOfFCSPLController.text = dpschemeIndex != -1
            ? settleOfFCSPLDropDownValues[dpschemeIndex]["description"]
            : "";
        settleOfFCSPLDropDownOptions.addAll(settleOfFCSPLDropDownValues
            .map((element) => element['description'])
            .toList());
      }
      var aggregatorStatus = await checkStatementFetch(context: context) ?? {};
      aggregatorDocID = aggregatorStatus['docid'] ?? "";
      aggregatorConsentID = aggregatorStatus['consentid'] ?? "";
      Map? demantServeResponse = await getServeBrokerDetailsApi(context);

      if (demantServeResponse != null) {
        brokerageHeading = demantServeResponse['brokhead'];
        edisDescription =
            demantServeResponse["dematinfo"]['edisDescription'] ?? "";
        disDescription =
            demantServeResponse["dematinfo"]['disDescription'] ?? "";
        brokerageData = demantServeResponse['brokdata'] ?? [];
        bankData = demantServeResponse['bankinfo'] ?? {};
        Map serviceResponse = demantServeResponse['service_map'] ?? {};
        serviceData = Map.fromEntries(serviceResponse.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)));
        titles.addAll(
            serviceData.values.map((element) => element['segement']).toList());

        List exchangeValues =
            serviceData.values.map((element) => element['exchange']).toList();

        List exchangenameLists = exchangeValues
            .map((sublist) =>
                sublist.map((exchange) => exchange['exchangename']).toList())
            .toList();

        subTitles = exchangenameLists.map((sublist) {
          return 'Trade in ${sublist.join(' ')}';
        }).toList();
        userSelects = serviceData.values
            .map((element) =>
                element['userstatus'] == 'Y' ? element['segement'] : '')
            .toList();
        selectedTile = serviceData.values
            .map((element) =>
                element['selected'] == 'Y' ? element['segement'] : '')
            .toList();
        isEdit = !(demantServeResponse['dematinfo']['dpscheme'] == null ||
            demantServeResponse['dematinfo']['dpscheme'].isEmpty);
        demantServeResponse['dematinfo']['dpscheme'] == null ||
                demantServeResponse['dematinfo']['dpscheme'].toString().isEmpty
            ? ""
            : dpSchemeController.text = demantDropDownValues.firstWhere(
                (element) =>
                    element['code'] ==
                    demantServeResponse['dematinfo']
                        ['dpscheme'])['description'];
        demantServeResponse['dematinfo']['runningAccSettlement'] == null ||
                demantServeResponse['dematinfo']['runningAccSettlement']
                    .toString()
                    .isEmpty
            ? ""
            : settleOfFCSPLController.text =
                settleOfFCSPLDropDownValues.firstWhere((element) =>
                    element['code'] ==
                    demantServeResponse['dematinfo']
                        ['runningAccSettlement'])['description'];
        tariffDetailsUrl =
            demantServeResponse['dematinfo']['tariffDetailsUrl'] ?? "";
        disValue =
            demantServeResponse['dematinfo']['dis'] == 'N' ? 'No' : 'Yes';
        eDisValue =
            demantServeResponse['dematinfo']['edis'] == 'Y' ? 'Yes' : 'No';
        oldDemantServ = createDematServiceJson();
        isLoading = false;
        if (mounted) {
          setState(() {});
        }
      }
      Navigator.pop(context);
    } catch (e) {
      showSnackbar(
          context,
          exceptionShowSnackBarContent(e.toString()) ?? "Some thing went wrong",
          Colors.red);
    }
  }

  /* 
  Purpose: This method is used to get the next route name from the api.
  */

  getNextRoute(context) async {
    loadingAlertBox(context);
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.segmentSelection],
      "routeraction": "Next"
    });
    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  /* 
  Purpose: This method is used create a map for service and Brokerage which is used for insert the values in the DB.
  */

  createDematServiceJson() {
    Map demantDetails = {
      "dpScheme": !isEdit
          ? ""
          : demantDropDownValues.firstWhere((element) =>
              element['description'] == dpSchemeController.text)['code'],
      "dis": disValue == 'Yes' ? 'Y' : 'N',
      "edis": eDisValue == 'Yes' ? 'Y' : 'N',
      "status": "",
      "runningAccSettlement": settleOfFCSPLDropDownValues.firstWhere(
          (element) =>
              element['description'] == settleOfFCSPLController.text)['code'],
    };
    for (var element in serviceData.keys) {
      !selectedTile.contains(serviceData[element]["segement"])
          ? serviceData[element]['selected'] = 'N'
          : serviceData[element]['selected'] = 'Y';
    }
    List serveIds = [];
    List brokIds = [];

    brokIds = brokerageData
        .map((sublist) => sublist[1])
        .map((element) => element.toString().split(',')[1])
        .map((e) => e.toString().split(':')[1])
        .toList();
    serveIds.addAll(serviceData.values
        .map((element) => element['selected'] == 'Y' ? element['exchange'] : [])
        .map((sublist) => sublist.map((exchange) => exchange['exchangeid']))
        .toList()
        .reduce((value, element) => [...value, ...element]));
    Map demantServ = {
      "dematinfo": demantDetails,
      "servicearr": serveIds,
      "brokeragearr": brokIds
    };
    isEdit = true;
    return demantServ;
  }

  /* 
  Purpose: This method is used to navigate to aggregator page based on the Response
  */

  movetoAggregator() async {
    String mobileNo = await getMobileNo();
    String email = await getEmail();
    if ((aggregatorDocID == "" ||
            (aggregatorDocID != "" && aggregatorConsentID == "")) &&
        mobileNo != CustomHttpClient.testMobileNo &&
        email != CustomHttpClient.testEmail) {
      Navigator.pushNamed(context, route.aggregator, arguments: {
        "mobileno": bankData["mobileno"] ?? "",
        "bankname": bankData["bankname"] ?? "",
        "maskaccount": bankData["maskaccount"] ?? "",
        "demantdata": createDematServiceJson(),
      });
    } else {
      insertSegmentDetails();
    }
  }

  /* 
  Purpose: This method is used insert the values in the DB
  */

  insertSegmentDetails() async {
    loadingAlertBox(context);
    Map newDemantServ = createDematServiceJson();
    var json = newDemantServ.toString() != oldDemantServ.toString()
        ? await insertDemantserveApi(context, newDemantServ)
        : "";
    if (mounted) {
      Navigator.pop(context);
    }
    if (json != null) {
      ProviderClass provider =
          Provider.of<ProviderClass>(context, listen: false);
      if (json != "" && provider.isEditPage) {
        Navigator.pushNamed(context, route.fileUpload);
      } else {
        getNextRoute(context);
      }
    }
  }

  Map htmlData = {};
  /* 
  Purpose: This method is used get the HTML Data for the the risk disclosure
  */
  getHtmlData() async {
    loadingAlertBox(context);
    var response = await getDishClosureData(
        context: context, contentType: "Risk Disclosure");
    Navigator.pop(context);
    if (response != null) {
      htmlData = response["riskDisclosure"];

      showTerms(
        context: context,
        htmlData: htmlData,
        func: movetoAggregator,
      );
    }
  }

  /* 
  Purpose: This method is used initialize the insert data and call that api method
  */

  insertData() async {
    if (selectedTile.where((element) => element != "").isEmpty) {
      showSnackbar(context, "please select the trading segments", Colors.red);
      return;
    }
    for (var element in serviceData.keys) {
      !selectedTile.contains(serviceData[element]["segement"])
          ? serviceData[element]['selected'] = 'N'
          : serviceData[element]['selected'] = 'Y';
    }
    serviceData.keys.any((element) =>
            serviceData[element]["selected"] == "Y" &&
            serviceData[element]["segement"] != "CASH AND MUTUAL FUND")
        ? getHtmlData()
        : insertSegmentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return StepWidget(
      endPoint: route.segmentSelection,
      step: 4,
      title: 'Bank & Segments',
      subTitle: 'Select your preferred segments',
      scrollController: scrollController,
      buttonFunc: insertData,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tariffDetailsUrl.isNotEmpty
                ? InkWell(
                    child: Text(
                      "DP TARIFF AND OTHER CHARGES",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    onTap: () async {
                      if (await canLaunchUrlString(tariffDetailsUrl)) {
                        launchUrlString(tariffDetailsUrl);
                      }
                    },
                  )
                : SizedBox(),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              'DP Scheme',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(
              height: 10.0,
            ),
            CustomDropDown(
              buttonSizeIsSmall: true,
              isIcon: true,
              label: 'Select DP Scheme',
              controller: dpSchemeController,
              values: demantDropDownOptions,
              formValidateNodifier: formValidateNodifierDpScheme,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              "Choose your trading segments",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(
              height: 10,
            ),
            ...List.generate(
              titles.length,
              (index) => CustomTile(
                title: titles[index],
                subtitle: subTitles[index],
                selectedTile: selectedTile,
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      if (userSelects.contains(titles[index])) {
                        selectedTile.contains(titles[index])
                            ? selectedTile.remove(titles[index])
                            : selectedTile.add(titles[index]);
                      }
                    });
                  }
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: 'Do you require DIS Slip Book ?',
                style: TextStyle(
                    fontSize: 12.0,
                    height: 1.7,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(102, 98, 98, 1)),
              ),
              WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Visibility(
                  visible: disDescription != "",
                  child: InkWell(
                    onTap: () {
                      showinfoalert(
                          context: context,
                          heading: "Note",
                          htmlcontent: disDescription);
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: const Color.fromRGBO(9, 101, 218, 1),
                      size: 18,
                    ),
                  ),
                ),
              )
            ])),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                buildCustomRadioButton('Yes', disValue ?? 'Yes', () {
                  if (mounted) {
                    setState(() {
                      disValue = 'Yes';
                      eDisValue = 'No';
                    });
                  }
                }),
                const SizedBox(width: 30.0),
                buildCustomRadioButton('No', disValue ?? "Yes", () {
                  if (mounted) {
                    setState(() {
                      disValue = 'No';
                      eDisValue = 'Yes';
                    });
                  }
                }),
              ],
            ),
            const SizedBox(
              height: 15.0,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text:
                    'Whether you are required to transact EDIS transaction for sale obligation?',
                style: TextStyle(
                    fontSize: 12.0,
                    height: 1.7,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(102, 98, 98, 1)),
              ),
              WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Visibility(
                  visible: edisDescription != "",
                  child: InkWell(
                    onTap: () {
                      showinfoalert(
                          context: context,
                          heading: "Note",
                          htmlcontent: edisDescription);
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: const Color.fromRGBO(9, 101, 218, 1),
                      size: 18,
                    ),
                  ),
                ),
              )
            ])),
            const SizedBox(
              height: 15.0,
            ),
            Row(
              children: [
                buildCustomRadioButton(
                  'Yes',
                  eDisValue ?? "No",
                  () {
                    if (mounted) {
                      setState(() {
                        eDisValue = 'Yes';
                        disValue = 'No';
                      });
                    }
                  },
                ),
                const SizedBox(width: 30.0),
                buildCustomRadioButton(
                  'No',
                  eDisValue ?? "No",
                  () {
                    if (mounted) {
                      setState(() {
                        eDisValue = 'No';
                        disValue = 'Yes';
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            const Text(
              'I / we authorize FCSPL to settle the funds atleast once in a calendar quarter / month as specified by me below in accordance with regulations in force.',
            ),
            const SizedBox(height: 10.0),
            CustomDropDown(
                buttonSizeIsSmall: true,
                controller: settleOfFCSPLController,
                values: settleOfFCSPLDropDownOptions,
                formValidateNodifier: formValidateNodifierDpScheme),
            if (brokerageHeading.isNotEmpty) ...[
              const SizedBox(
                height: 20.0,
              ),
              BrockerageConatiner(
                brokData: brokerageData,
                brokHead: brokerageHeading,
              ),
            ],
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ],
    );
  }

  Widget buildCustomRadioButton(
      String value, String groupValue, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          CustomRadioButton(
            color: groupValue == value
                ? const Color.fromRGBO(9, 101, 218, 1)
                : Colors.transparent,
          ),
          const SizedBox(width: 10.0),
          Text(value),
        ],
      ),
    );
  }
}

class BrockerageConatiner extends StatelessWidget {
  final List brokData;
  final List brokHead;
  final bool? isSmall;

  const BrockerageConatiner({
    super.key,
    required this.brokData,
    required this.brokHead,
    this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: EdgeInsets.only(left: 5.0, bottom: 3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color.fromRGBO(93, 140, 201, 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...brokHead.map(
                      (element) => SizedBox(
                        width: isSmall == true
                            ? (MediaQuery.of(context).size.width * 0.5) - 70.0
                            : (MediaQuery.of(context).size.width * 0.5) - 35.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            element,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    brokData.length,
                    (index) {
                      return Container(
                        decoration: BoxDecoration(
                            border: Border(
                          bottom: index == brokData.length - 1
                              ? BorderSide.none
                              : const BorderSide(
                                  width: 0.5,
                                ),
                        )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: isSmall == true
                                  ? (MediaQuery.of(context).size.width * 0.5) -
                                      70.0
                                  : (MediaQuery.of(context).size.width * 0.5) -
                                      35.0,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: const BorderSide(
                                    width: 0.25,
                                  ),
                                ),
                              ),
                              child: Text(brokData[index][0]),
                            ),
                            Container(
                              width: isSmall == true
                                  ? (MediaQuery.of(context).size.width * 0.5) -
                                      70.0
                                  : (MediaQuery.of(context).size.width * 0.5) -
                                      35.0,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: const BorderSide(
                                    width: 0.25,
                                  ),
                                ),
                              ),
                              child: Text(
                                brokData[index][1].toString().split(',').first,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
