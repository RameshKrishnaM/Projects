import 'dart:convert';
import 'dart:io';

import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Custom%20Widgets/StepWidget.dart';
import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackBar.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../API call/api_call.dart';
import '../Cookies/HttpClient.dart';
import '../Custom Widgets/Custom.dart';
import '../Custom Widgets/custom_button.dart';
import '../Custom Widgets/subtile.dart';
import '../Model/getfromdata_modal.dart';
import '../Route/route.dart' as route;

class NomineeDashboard extends StatefulWidget {
  final bool? isBack;
  const NomineeDashboard({super.key, this.isBack});

  @override
  State<NomineeDashboard> createState() => _NomineeDashboardState();
}

class _NomineeDashboardState extends State<NomineeDashboard> {
  int getlength = 0;
  String name1 = '';
  String name2 = '';
  String name3 = '';
  String percentage1 = "";
  String percentage2 = "";
  String percentage3 = "";
  String relationShip1 = "";
  String relationShip2 = "";
  String relationShip3 = "";
  num percentage = 0;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    postmap = Provider.of<Postmap>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getfomrdetails();
    });
    super.initState();
  }

  getfomrdetails() async {
    loadingAlertBox(context);
    List<Map<String, dynamic>> nomineesInProvider = postmap.response;
    // print("res $nomineesInProvider");
    if (nomineesInProvider.isNotEmpty) {
      getNomineeNames(nomineesInProvider);
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    try {
      var json = await getNomineeAPI(context: context);
      if (json != null) {
        // Map json = jsonDecode(response.body);
        // print("start");
        // for (var element in json["nominee"][0].keys) {
        //   print("$element : ${json["nominee"][0][element]}");
        // }

        if (json['nominee'] != null && json['nominee'].isNotEmpty) {
          getlength = json['nominee']!.length;

          var formdata = GetfromdataModal.fromJson(json);

          var n1 = formdata.nominee[0];

          name1 = n1.nomineeName;
          relationShip1 = n1.nomineerelationshipdesc;
          percentage1 = n1.nomineeShare;
          if (getlength > 1) {
            var n2 = formdata.nominee[1];
            name2 = n2.nomineeName;
            relationShip2 = n2.nomineerelationshipdesc;
            percentage2 = n2.nomineeShare;
          }
          if (getlength > 2) {
            var n3 = formdata.nominee[2];
            name3 = n3.nomineeName;
            relationShip3 = n3.nomineerelationshipdesc;
            percentage3 = n3.nomineeShare;
          }
          percentage = formdata.nominee.fold(
              0,
              (previousValue, element) =>
                  previousValue + (int.tryParse(element.nomineeShare) ?? 0));

          List<Map<String, dynamic>> nominees = [];
          json["nominee"].map((nominee) {
            Map<String, dynamic> data = {...nominee};

            // String nomineeRelationship = data["NomineeRelationship"];
            // data["NomineeRelationship"] = nomineeRelationship.split(",")[1];
            // data["NomineeRelationshipdesc"] = nomineeRelationship.split(",")[0];

            // data["NomineeProofOfIdentity"] =
            //     data["NomineeProofOfIdentity"].toString().split(",")[1];
            // // data["NomineeProofOfIdentitydesc"] =
            // //     data["NomineeProofOfIdentity"].toString().split(",")[0];

            // data["GuardianRelationship"] =
            //     data["GuardianRelationship"].toString().split(",")[1];
            // // data["GuardianRelationshipdesc"] =
            // //     data["GuardianRelationship"].toString().split(",")[0];

            // data["GuardianProofOfIdentity"] =
            //     data["GuardianProofOfIdentity"].toString().split(",")[1];

            // print(data);
            nominees.add(data);
          }).toList();
          postmap.changeResponse(nominees);
          postmap.changeGetResponse([...nominees]);
          // print("dadad ${postmap.response}");
          if (mounted) {
            Navigator.pop(context);
          }
          // print(postmap.response);
        } else {
          if (mounted) {
            Navigator.pop(context);
          }
          if (widget.isBack != true) {
            Navigator.pushNamed(context, route.addNominee,
                    arguments: {"nominee": "Nominee 1"})
                .then((value) => getNomineeDetaislInProvider());
          }
        }
        if (mounted) {
          setState(() {});
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // print("object");
      // print(e);
    }
  }

  getNomineeNames(List<Map<String, dynamic>> nominees) {
    nominees = nominees
        .where((nominee) => nominee["ModelState"] != "deleted")
        .toList();
    getlength = nominees.length;
    // print(getlength);
    if (nominees.isNotEmpty) {
      name1 = nominees[0]["nomineename"];
      percentage1 = nominees[0]["nomineeshare"];
      relationShip1 = nominees[0]["nomineerelationshipdesc"];
    }
    if (nominees.length > 1) {
      name2 = nominees[1]["nomineename"];
      percentage2 = nominees[1]["nomineeshare"];
      relationShip2 = nominees[1]["nomineerelationshipdesc"];
    }
    if (nominees.length > 2) {
      name3 = nominees[2]["nomineename"];
      percentage3 = nominees[2]["nomineeshare"];
      relationShip3 = nominees[2]["nomineerelationshipdesc"];
    }
    percentage = nominees.fold(
        0,
        (previousValue, element) =>
            previousValue + (int.tryParse(element["nomineeshare"]) ?? 0));
    if (mounted) {
      setState(() {});
    }
  }

  addNomineeDetailsInAPICall() async {
    List<Map<String, dynamic>> nomineesDetails = postmap.response;
    List<Map<String, dynamic>> getNomineesDetails = postmap.getresponse;
    List deleteIds = [];
    List<Map<String, dynamic>> nomineesDetailsForPercentage =
        nomineesDetails.where((nominee) {
      if (nominee["ModelState"] == "deleted") {
        deleteIds.add(nominee["NomineeID"]);
      }
      return nominee["ModelState"] != "deleted";
    }).toList();
    num percentage = nomineesDetailsForPercentage.fold(
        0,
        (previousValue, element) =>
            previousValue + (int.tryParse(element["nomineeshare"]) ?? 0));

    if (percentage != 100) {
      showSnackbar(
          context,
          "Nominee total share percentage is $percentage , which is ${percentage > 100 ? "greater" : "lesser"} than 100",
          Colors.red);
      return;
    }
    loadingAlertBox(context);

    var response = nomineesDetails.toString() != getNomineesDetails.toString()
        ? await addNomineeAPI(
            context: context, deleteIds: [], inputJsonData: nomineesDetails)
        : "";
    if (response != null) {
      getNextRoute(context);
      postmap.changeResponse([]);
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  getNextRoute(context) async {
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.nominee],
      "routeraction": "Next"
    });
    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, response["endpoint"], (route) => route.isFirst);
    }
  }

  deleteNomineeDetails(int index) {
    List<Map<String, dynamic>> nominees = postmap.response;
    // if (nominees[index]["id"] == 0) {
    //   nominees.removeAt(index);
    // } else {
    //   nominees[index]["ModelState"] = "deleted";
    // }
    List<Map<String, dynamic>> tempNominees = nominees
        .where((nominee) => nominee["ModelState"] != "deleted")
        .toList();
    index = nominees.indexOf(tempNominees[index]);
    nominees[index]["NomineeID"] == 0
        ? nominees.removeAt(index)
        : nominees[index]["ModelState"] = "deleted";
    postmap.changeResponse(nominees);
    getNomineeNames(nominees);
  }

  getNomineeDetaislInProvider() {
    List<Map<String, dynamic>> nomineesInProvider = postmap.response;
    getNomineeNames(nomineesInProvider);
  }

  late Postmap postmap;
  @override
  void dispose() {
    postmap.chenageResponseToEmpty();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepWidget(
        endPoint: route.nominee,
        step: 3,
        title: 'Nomination & Declaration',
        subTitle: 'Add up to three nominees to your Demat & Trading account.',
        scrollController: scrollController,
        buttonFunc: () => addNomineeDetailsInAPICall(),
        children: [
          // ...getTitleANdSubTitleWidget(
          //     'Nomination & Declaration',
          //     'Add up to three nominees to your Demat & Trading account.',
          //     context),
          getlength > 0
              ? Subtile(
                  Ontap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) =>
                    //       AddNomineeForm(nom: 'Nominee 1'),
                    // ));
                    // Navigator.pushNamed(context, route.addNominee,
                    //     arguments: {
                    //       "nominee": "Nominee 1",
                    //       "nomineeDetails":
                    //           Provider.of<Postmap>(context, listen: false)
                    //               .response[0]
                    //     }).then((value) => getNomineeDetaislInProvider());
                    showNomineeDetailsBottomSheet(0, context);
                  },
                  // svg: 'assets/images/greenperson.svg',
                  // mainColor: Color(0xFF32BA7C),
                  content: name1,
                  percentage: percentage1,
                  relationShip: relationShip1,
                  deleteFunc: () => deleteNomineeDetails(0),
                )
              : Subtile(
                  Ontap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) =>
                    //       AddNomineeForm(nom: 'Nominee 1'),
                    // ));
                    Navigator.pushNamed(context, route.addNominee,
                            arguments: {"nominee": "Nominee 1"})
                        .then((value) => getNomineeDetaislInProvider());
                  },
                  // svg: 'assets/images/blackperson.svg',
                  // mainColor: Color(0xFF32BA7C),
                  content: "Nominee 1",
                ),
          SizedBox(
            height: 30,
          ),
          getlength > 1
              ? Subtile(
                  Ontap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) =>
                    //       AddNomineeForm(nom: 'Nominee 2'),
                    // ));
                    // Navigator.pushNamed(context, route.addNominee,
                    //     arguments: {
                    //       "nominee": "Nominee 2",
                    //       "nomineeDetails":
                    //           Provider.of<Postmap>(context, listen: false)
                    //               .response[1]
                    //     }).then((value) => getNomineeDetaislInProvider());
                    showNomineeDetailsBottomSheet(1, context);
                  },
                  // svg: 'assets/images/greenperson.svg',
                  // mainColor: Color(0xFF32BA7C),
                  content: name2,
                  percentage: percentage2,
                  relationShip: relationShip2,
                  deleteFunc: () => deleteNomineeDetails(1),
                )
              : Subtile(
                  isDisable: !(getlength == 1) || percentage >= 100,
                  Ontap: getlength == 1 && percentage < 100
                      ? () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context) =>
                          //       AddNomineeForm(nom: 'Nominee 1'),
                          // ));
                          Navigator.pushNamed(context, route.addNominee,
                                  arguments: {"nominee": "Nominee 2"})
                              .then((value) => getNomineeDetaislInProvider());
                        }
                      : getlength == 1 && percentage >= 100
                          ? () => showSnackbar(
                              context, "nominee percentage is 100%", Colors.red)
                          : () {},
                  // svg: 'assets/images/blackperson.svg',
                  // mainColor: Color(0xFF32BA7C),
                  content: "Nominee 2",
                ),
          SizedBox(
            height: 30,
          ),
          getlength > 2
              ? Subtile(
                  // isDisable: !(getlength == 2),
                  Ontap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) =>
                    //       AddNomineeForm(nom: 'Nominee 3'),
                    // ));
                    // Navigator.pushNamed(context, route.addNominee,
                    //     arguments: {
                    //       "nominee": "Nominee 3",
                    //       "nomineeDetails":
                    //           Provider.of<Postmap>(context, listen: false)
                    //               .response[2]
                    //     }).then((value) => getNomineeDetaislInProvider());
                    showNomineeDetailsBottomSheet(2, context);
                  },
                  // svg: 'assets/images/greenperson.svg',
                  // mainColor: Color(0xFF32BA7C),
                  content: name3,
                  percentage: percentage3,
                  relationShip: relationShip3,
                  deleteFunc: () => deleteNomineeDetails(2),
                )
              : Subtile(
                  isDisable: !(getlength == 2) || percentage >= 100,
                  Ontap: getlength == 2 && percentage < 100
                      ? () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context) =>
                          //       AddNomineeForm(nom: 'Nominee 1'),
                          // ));
                          Navigator.pushNamed(context, route.addNominee,
                                  arguments: {"nominee": "Nominee 3"})
                              .then((value) => getNomineeDetaislInProvider());
                        }
                      : getlength == 2 && percentage >= 100
                          ? () => showSnackbar(
                              context, "nominee percentage is 100%", Colors.red)
                          : () {},
                  // svg: 'assets/images/blackperson.svg',
                  // mainColor: Color(0xFF32BA7C),
                  content: "Nominee 3",
                ),
          // getlength<3?
        ]);
  }

  perviewFile(String title, String id, isNominee) async {
    File? file = postmap.getFile(title, isNominee);

    String? fileName = postmap.getFileName(title, isNominee);
    print(fileName);
    if (file != null) {
      Navigator.pushNamed(context,
          file.path.endsWith(".pdf") ? route.previewPdf : route.previewImage,
          arguments: {
            "title": "${title.replaceAll(" ", "")}Proof",
            "data": file.readAsBytesSync(),
            "fileName": fileName
          });
      return;
    }
    loadingAlertBox(context);
    List? nomineeFileDetails = id.isNotEmpty
        ? await fetchFile(context: context, id: id, list: true)
        : null;
    if (mounted) {
      Navigator.pop(context);
    }
    if (nomineeFileDetails != null) {
      Navigator.pushNamed(
          context,
          nomineeFileDetails[0].toString().endsWith(".pdf")
              ? route.previewPdf
              : route.previewImage,
          arguments: {
            "title": "${title.replaceAll(" ", "")}Proof",
            "data": nomineeFileDetails[1],
            "fileName": nomineeFileDetails[0]
          });
    }
  }

  showNomineeDetailsBottomSheet(int index, pageConext) {
    String nom = "Nominee ${index + 1}";
    Map<String, dynamic> nomineeDetails = postmap.response
        .where((nominee) => nominee["ModelState"] != "deleted")
        .toList()[index];
    Nominee nominee = Nominee.fromJson(nomineeDetails);
    List nomineeProofDetails = [
      {
        "title": "Proof of Identity",
        "value": nominee.nomineeproofofidentitydesc
      },
      {"title": "Proof Number", "value": nominee.nomineeProofNumber},
      {"title": "Date of Issue", "value": nominee.nomineeproofdateofissue},
      {"title": "Date of Expiry", "value": nominee.nomineeproofexpriydate},
      {"title": "Place of Issue", "value": nominee.nomineeplaceofissue},
      {"title": "Proof Attach", "value": "PREVIEW NOMINEE PROOF"}
    ]
        .where((element) =>
            element["value"] != null && element["value"]!.isNotEmpty)
        .toList();
    List guardianProofDetails = [
      {
        "title": "Proof of Identity",
        "value": nominee.guardianproofofidentitydesc
      },
      {"title": "Proof Number", "value": nominee.guardianProofNumber},
      {"title": "Date of Issue", "value": nominee.guardianproofdateofissue},
      {"title": "Date of Expiry", "value": nominee.guardianproofexpriydate},
      {"title": "Place of Issue", "value": nominee.guardianplaceofissue},
      {"title": "Proof Attach", "value": "PREVIEW NOMINEE PROOF"}
    ]
        .where((element) =>
            element["value"] != null && element["value"]!.isNotEmpty)
        .toList();
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(7.0), topRight: Radius.circular(7.0))),
      context: context,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          padding: const EdgeInsets.all(25.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(9, 101, 218, 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              width: 1.0,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!)),
                      child: Row(children: [
                        Icon(
                          CupertinoIcons.arrow_uturn_left,
                          size: 12.0,
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          "Back",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 12.0),
                        )
                      ]),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(''),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomDataRow(
                  title1: "Nominee Name",
                  value1: "${nominee.nomineeTitle}.${nominee.nomineeName}",
                  title2: "Relationship",
                  value2: nominee.nomineerelationshipdesc),
              const SizedBox(height: 10),
              CustomDataRow(
                  title1: "Percentage of Share",
                  value1: nominee.nomineeShare,
                  title2: "Date of Birth",
                  value2: nominee.nomineeDob),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Address",
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: const Color.fromRGBO(195, 195, 195, 1),
                                fontSize: 15.0,
                              )),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    "${nominee.nomineeAddress1}, ${nominee.nomineeAddress2}, ${nominee.nomineeAddress3.isNotEmpty ? "${nominee.nomineeAddress3}, " : ""}, ${nominee.nomineeCity}, ${nominee.nomineeState}, ${nominee.nomineeCountry}, ${nominee.nomineePincode}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  )
                ],
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < nomineeProofDetails.length;) ...[
                nomineeProofDetails[i]["title"] != "Proof Attach" &&
                        nomineeProofDetails[i + 1]["title"] != "Proof Attach"
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: CustomDataRow(
                          title1: nomineeProofDetails[i]["title"],
                          value1: nomineeProofDetails[i++]["value"],
                          title2: i < nomineeProofDetails.length
                              ? nomineeProofDetails[i]["title"]
                              : "",
                          value2: i < nomineeProofDetails.length
                              ? nomineeProofDetails[i++]["value"]
                              : "",
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          children: [
                            if (nomineeProofDetails[i]["title"] !=
                                "Proof Attach") ...[
                              Expanded(
                                  child: CustomColumnWidget(
                                      title: nomineeProofDetails[i]["title"],
                                      value: nomineeProofDetails[i++]
                                          ["value"])),
                              const SizedBox(width: 10.0),
                            ],
                            Visibility(
                              visible:
                                  nominee.nomineeFileUploadDocIds.isNotEmpty ||
                                      postmap.getFile(nom, true) != null,
                              child: Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nomineeProofDetails[i++]["title"],
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              color: const Color.fromRGBO(
                                                  195, 195, 195, 1),
                                              fontSize: 15.0,
                                            )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    InkWell(
                                      child: Text(
                                        "PREVIEW NOMINEE PROOF",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                      onTap: () => perviewFile(
                                          nom,
                                          nominee.nomineeFileUploadDocIds,
                                          true),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],

              // CustomDataRow(
              //   title1: "Proof of Identity",
              //   value1: nominee.nomineeproofofidentitydesc,
              //   title2: "Proof Number",
              //   value2: nominee.nomineeProofNumber,
              // ),
              // const SizedBox(height: 10),
              // CustomDataRow(
              //     title1: "Date of Issue",
              //     value1: nominee.nomineeproofdateofissue,
              //     title2: nominee.nomineeproofexpriydate.isNotEmpty
              //         ? "Date of Expiry"
              //         : "Place of Issue",
              //     value2: nominee.nomineeproofexpriydate.isNotEmpty
              //         ? nominee.nomineeproofexpriydate
              //         : nominee.nomineeplaceofissue),
              // const SizedBox(height: 10),
              // Row(
              //   children: [
              //     if (nominee.nomineeproofexpriydate.isNotEmpty) ...[
              //       Expanded(
              //           child: CustomColumnWidget(
              //               title: "Place of Issue",
              //               value: nominee.nomineeplaceofissue)),
              //       const SizedBox(width: 10.0),
              //     ],
              //     Visibility(
              //       visible: nominee.nomineeFileUploadDocIds.isNotEmpty,
              //       child: Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text("Proof Attach",
              //                 style: Theme.of(context)
              //                     .textTheme
              //                     .displayMedium!
              //                     .copyWith(
              //                       color:
              //                           const Color.fromRGBO(195, 195, 195, 1),
              //                       fontSize: 15.0,
              //                     )),
              //             const SizedBox(
              //               height: 3,
              //             ),
              //             InkWell(
              //               child: Text(
              //                 "PREVIEW NOMINEE PROOF",
              //                 style: Theme.of(context)
              //                     .textTheme
              //                     .bodyMedium!
              //                     .copyWith(
              //                         fontWeight: FontWeight.w500,
              //                         color: Theme.of(context)
              //                             .colorScheme
              //                             .primary),
              //               ),
              //               onTap: () => perviewFile(
              //                   nom, nominee.nomineeFileUploadDocIds, true),
              //             )
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 10),
              if (nominee.guardianVisible) ...[
                DottedLine(),
                const SizedBox(height: 10),
                CustomDataRow(
                    title1: "Guardian Name",
                    value1: "${nominee.guardianTitle}.${nominee.guardianName}",
                    title2: "Relationship",
                    value2: nominee.guardianrelationshipdesc),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Address",
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  color: const Color.fromRGBO(195, 195, 195, 1),
                                  fontSize: 15.0,
                                )),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      "${nominee.guardianAddress1}, ${nominee.guardianAddress2}, ${nominee.guardianAddress3.isNotEmpty ? "${nominee.guardianAddress3}, " : ""}, ${nominee.guardianCity}, ${nominee.guardianState}, ${nominee.guardianCountry}, ${nominee.guardianPincode}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                CustomDataRow(
                    title1: "Phone Number",
                    value1: nominee.guardianMobileNo,
                    title2: "Email ID",
                    value2: nominee.guardianEmailId),
                const SizedBox(height: 10),
                for (int i = 0; i < guardianProofDetails.length;) ...[
                  guardianProofDetails[i]["title"] != "Proof Attach" &&
                          guardianProofDetails[i + 1]["title"] != "Proof Attach"
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: CustomDataRow(
                            title1: guardianProofDetails[i]["title"],
                            value1: guardianProofDetails[i++]["value"],
                            title2: i < guardianProofDetails.length
                                ? guardianProofDetails[i]["title"]
                                : "",
                            value2: i < guardianProofDetails.length
                                ? guardianProofDetails[i++]["value"]
                                : "",
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              if (guardianProofDetails[i]["title"] !=
                                  "Proof Attach") ...[
                                Expanded(
                                    child: CustomColumnWidget(
                                        title: guardianProofDetails[i]["title"],
                                        value: guardianProofDetails[i++]
                                            ["value"])),
                                const SizedBox(width: 10.0),
                              ],
                              Visibility(
                                visible: nominee
                                        .guardianFileUploadDocIds.isNotEmpty ||
                                    postmap.getFile(nom, false) != null,
                                child: Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(guardianProofDetails[i++]["title"],
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                color: const Color.fromRGBO(
                                                    195, 195, 195, 1),
                                                fontSize: 15.0,
                                              )),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      InkWell(
                                        child: Text(
                                          "PREVIEW NOMINEE PROOF",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                        ),
                                        onTap: () => perviewFile(
                                            nom,
                                            nominee.guardianFileUploadDocIds,
                                            false),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
                // CustomDataRow(
                //   title1: "Proof of Identity",
                //   value1: nominee.guardianproofofidentitydesc,
                //   title2: "Proof Number",
                //   value2: nominee.guardianProofNumber,
                // ),
                // const SizedBox(height: 10),
                // CustomDataRow(
                //     title1: "Date of Issue",
                //     value1: nominee.guardianproofdateofissue,
                //     title2: nominee.guardianproofexpriydate.isNotEmpty
                //         ? "Date of Expiry"
                //         : "Place of Issue",
                //     value2: nominee.guardianproofexpriydate.isNotEmpty
                //         ? nominee.guardianproofexpriydate
                //         : nominee.guardianplaceofissue),
                // const SizedBox(height: 10),
                // Row(
                //   children: [
                //     if (nominee.guardianproofexpriydate.isNotEmpty) ...[
                //       Expanded(
                //           child: CustomColumnWidget(
                //               title: "Place of Issue",
                //               value: nominee.guardianplaceofissue)),
                //       const SizedBox(width: 10.0),
                //     ],
                //     Expanded(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text("Proof Attach",
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .displayMedium!
                //                   .copyWith(
                //                     color:
                //                         const Color.fromRGBO(195, 195, 195, 1),
                //                     fontSize: 15.0,
                //                   )),
                //           const SizedBox(
                //             height: 3,
                //           ),
                //           InkWell(
                //             child: Text(
                //               "PREVIEW GUARDIAN PROOF",
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .bodyMedium!
                //                   .copyWith(
                //                       fontWeight: FontWeight.w500,
                //                       color: Theme.of(context)
                //                           .colorScheme
                //                           .primary),
                //             ),
                //             onTap: () => perviewFile(
                //                 nom, nominee.guardianFileUploadDocIds, false),
                //           )
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                      child: CustomButton(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Flexible(
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 1)),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                SvgPicture.asset("assets/images/VectorEdit.svg",
                                    color: Colors.white),
                              ]),
                          buttonFunc: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                                context, route.addNominee, arguments: {
                              "nominee": nom,
                              "nomineeDetails": nomineeDetails
                            }).then((value) => getNomineeDetaislInProvider());
                          })),
                  const SizedBox(width: 10.0),
                  Expanded(
                      child: CustomButton(
                          color: Colors.red,
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 1)),
                                  ),
                                ),
                                SizedBox(width: 7),
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ]),
                          buttonFunc: () {
                            Navigator.pop(context);
                            openAlertBox(
                                context: pageConext,
                                content:
                                    "Do you want Delete the ${nominee.nomineeName} Details?",
                                onpressedButton1: () {
                                  Navigator.pop(pageConext);
                                  deleteNomineeDetails(index);
                                });
                          })),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
