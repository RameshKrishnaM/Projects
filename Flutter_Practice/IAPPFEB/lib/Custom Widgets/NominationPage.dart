import 'package:ekyc/Custom%20Widgets/scrollable_widget.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:flutter/material.dart';

import '../API call/api_call.dart';
import '../Model/Total_api.dart';
import '../Model/route_model.dart';
import 'Custom.dart';
import 'error_message.dart';
import '../Route/route.dart' as route;

// import '../Expansion/Custom.dart';

class NominationPage extends StatefulWidget {
  final Nominearr? nominee;
  final String name;
  final String dob;
  final String proofNo;
  final String city;
  final String state;
  final String pinCode;
  final String nomineeProof;
  final String nominRelation;
  final ScrollController scrollController;
  final RouteModel? routeDetails;
  const NominationPage({
    Key? key,
    this.nominee,
    required this.name,
    required this.dob,
    required this.proofNo,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.nomineeProof,
    required this.nominRelation,
    required this.scrollController,
    this.routeDetails,
  }) : super(key: key);
  @override
  State<NominationPage> createState() => _NominationPageState();
}

class _NominationPageState extends State<NominationPage> {
  @override
  Widget build(BuildContext context) {
    return CustomStyledContainer(
      child: ScrollableWidget(
        controller: widget.scrollController,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ErrorMessageContainer(routeDetails: widget.routeDetails),
              widget.nominee != null &&
                      widget.nominee!.guardianname != null &&
                      widget.nominee!.guardianname.isNotEmpty
                  ? Text(
                      'Nominee Details ',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color:
                              Theme.of(context).textTheme.displayMedium!.color,
                          fontWeight: FontWeight.w500),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 10.0,
              ),
              CustomDataRow(
                title1: 'Name',
                value1: widget.name,
                title2: 'Date of birth',
                value2: widget.dob,
              ),
              const SizedBox(
                height: 20.0,
              ),
              CustomDataRow(
                title1: widget.nomineeProof,
                value1: widget.proofNo,
                title2: 'Relation',
                value2: widget.nominRelation,
              ),
              const SizedBox(
                height: 20.0,
              ),
              CustomDataRow(
                title1: 'City',
                value1: widget.city,
                title2: 'State',
                value2: widget.state,
              ),
              const SizedBox(
                height: 20.0,
              ),
              CustomColumnWidget(title: 'Pincode', value: widget.pinCode),
              const SizedBox(
                height: 20.0,
              ),
              if (widget.nominee != null &&
                  widget.nominee!.guardianname != null &&
                  widget.nominee!.guardianname!.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DottedLine(),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Guardian Details ',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .color,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    CustomDataRow(
                      title1: 'Name',
                      value1: widget.nominee!.guardianname!,
                      title2: 'Relationship ',
                      value2: widget.nominee!.guardianrelationship ?? '',
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    CustomDataRow(
                      title1: widget.nominee!.guardianproofofidentity ?? '',
                      value1: widget.nominee!.guardianproofnumber ?? '',
                      title2: 'City',
                      value2: widget.nominee!.guardiancity ?? '',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NomineeNewPage extends StatefulWidget {
  final ScrollController scrollController;
  final Nominearr nominee;
  final RouteModel? routeDetails;
  const NomineeNewPage(
      {super.key,
      required this.nominee,
      required this.scrollController,
      this.routeDetails});

  @override
  State<NomineeNewPage> createState() => _NomineeNewPageState();
}

class _NomineeNewPageState extends State<NomineeNewPage> {
  preViewFile({required id, required title}) async {
    loadingAlertBox(context);
    List? nomineeFileDetails = id.isNotEmpty
        ? await fetchFile(context: context, id: id, list: true)
        : null;
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    List nomineeProofDetails = [
      {"title": "Phone Number", "value": widget.nominee.nomineemobileno},
      {"title": "Email ID", "value": widget.nominee.nomineeemailid},
      {"title": "Proof Number", "value": widget.nominee.nomineeproofnumber},
      {
        "title": "Date of Issue",
        "value": widget.nominee.nomineeproofdateofissue
      },
      {
        "title": "Date of Expiry",
        "value": widget.nominee.nomineeproofexpriydate
      },
      {"title": "Place of Issue", "value": widget.nominee.nomineeplaceofissue},
      {"title": "Proof Attach", "value": "PREVIEW NOMINEE PROOF"}
    ]
        .where((element) =>
            element["value"] != null && element["value"]!.isNotEmpty)
        .toList();
    List guardianProofDetails = [
      {
        "title": "Proof of Identity",
        "value": widget.nominee.guardianproofofidentity
      },
      {"title": "Proof Number", "value": widget.nominee.guardianproofnumber},
      {
        "title": "Date of Issue",
        "value": widget.nominee.guardianproofdateofissue
      },
      {
        "title": "Date of Expiry",
        "value": widget.nominee.guardianproofexpriydate
      },
      {"title": "Place of Issue", "value": widget.nominee.guardianplaceofissue},
      {"title": "Proof Attach", "value": "PREVIEW NOMINEE PROOF"}
    ]
        .where((element) =>
            element["value"] != null && element["value"]!.isNotEmpty)
        .toList();
    return CustomStyledContainer(
      child: ScrollableWidget(
        controller: widget.scrollController,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ErrorMessageContainer(routeDetails: widget.routeDetails),
              Text(
                'Nominee Details ',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).textTheme.displayMedium!.color,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 10.0,
              ),
              CustomDataRow(
                  title1: "Nominee Name",
                  value1:
                      "${widget.nominee.nomineetitle}.${widget.nominee.nomineename}",
                  title2: "Relationship",
                  value2: widget.nominee.nomineerelationship),
              const SizedBox(height: 10),
              CustomDataRow(
                  title1: "Percentage of Share",
                  value1: widget.nominee.nomineeshare,
                  title2: "Date of Birth",
                  value2: widget.nominee.nomineedob),
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
                    "${widget.nominee.nomineeaddress1}, ${widget.nominee.nomineeaddress2.isNotEmpty ? "${widget.nominee.nomineeaddress2}, " : ""}${widget.nominee.nomineeaddress3.isNotEmpty ? "${widget.nominee.nomineeaddress3}, " : ""}${widget.nominee.nomineecity}, ${widget.nominee.nomineestate}, ${widget.nominee.nomineecountry}, ${widget.nominee.nomineepincode}",
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              visible: widget
                                  .nominee.nomineefileuploaddocids.isNotEmpty,
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
                                      onTap: () => preViewFile(
                                          id: widget
                                              .nominee.nomineefileuploaddocids,
                                          title: "nominee_proof"),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
              const SizedBox(height: 10),
              if (widget.nominee.guardianname.isNotEmpty) ...[
                DottedLine(),
                const SizedBox(height: 10),
                CustomDataRow(
                    title1: "Guardian Name",
                    value1:
                        "${widget.nominee.guardiantitle}.${widget.nominee.guardianname}",
                    title2: "Relationship",
                    value2: widget.nominee.guardianrelationship),
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
                      "${widget.nominee.guardianaddress1}, ${widget.nominee.guardianaddress2}, ${widget.nominee.guardianaddress3.isNotEmpty ? "${widget.nominee.guardianaddress3}, " : ""}${widget.nominee.guardiancity}, ${widget.nominee.guardianstate}, ${widget.nominee.guardiancountry}, ${widget.nominee.guardianpincode}",
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
                    value1: widget.nominee.guardianmobileno,
                    title2: "Email ID",
                    value2: widget.nominee.guardianemailid),
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
                                visible: widget.nominee.guardianfileuploaddocids
                                    .isNotEmpty,
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
                                        onTap: () => preViewFile(
                                            id: widget.nominee
                                                .guardianfileuploaddocids,
                                            title: "guardian_proof"),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
    ;
  }
}
