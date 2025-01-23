import 'package:ekyc/Custom%20Widgets/error_message.dart';
import 'package:flutter/material.dart';

import '../API call/api_call.dart';
import '../Model/route_model.dart';
import '../Screens/signup.dart';
import 'custom.dart';
import '../Route/route.dart' as route;

class PanAadhaarDetail extends StatefulWidget {
  final String name;
  final String dob;
  final String pan;
  final String sourceOfAddress;
  final String permanentAddress;
  final String correspondenceAddress;
  final String proofType;
  final String proofNo;
  final String perproofdateofisu;
  final String perproofplaceofisu;
  final String perproofexpirydate;
  final String proofFileId1;
  final String proofFileId2;
  final String addressType1;
  final String addressType2;
  final String coradrsproofname;
  final String coradrsproofno;
  final String coradrsproofplaceisu;
  final String coradrsproofisudate;
  final String corproofexpirydate;
  final String cordocid1;
  final String cordocid2;

  final RouteModel? routeDetails;

  const PanAadhaarDetail({
    super.key,
    required this.name,
    required this.dob,
    required this.pan,
    required this.sourceOfAddress,
    required this.proofType,
    required this.permanentAddress,
    required this.correspondenceAddress,
    this.routeDetails,
    required this.proofNo,
    required this.proofFileId1,
    required this.proofFileId2,
    required this.addressType1,
    required this.addressType2,
    required this.perproofdateofisu,
    required this.perproofplaceofisu,
    required this.perproofexpirydate,
    required this.coradrsproofname,
    required this.coradrsproofno,
    required this.coradrsproofplaceisu,
    required this.coradrsproofisudate,
    required this.corproofexpirydate,
    required this.cordocid1,
    required this.cordocid2,
  });

  @override
  State<PanAadhaarDetail> createState() => _PanAadhaarDetailState();
}

class _PanAadhaarDetailState extends State<PanAadhaarDetail> {
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
    return CustomStyledContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErrorMessageContainer(routeDetails: widget.routeDetails),
          CustomDataRow(
            title1: 'Name',
            value1: widget.name,
            title2: 'Date of birth',
            value2: widget.dob,
          ),
          const SizedBox(
            height: 20,
          ),
          CustomDataRow(
            title1: 'PAN',
            value1: widget.pan,
            title2: 'Soure of Address',
            value2: widget.sourceOfAddress,
          ),
          const SizedBox(
            height: 20,
          ),
          CustomColumnWidget(
              title: widget.addressType1.isNotEmpty
                  ? widget.addressType1
                  : 'Permanent Address',
              value: widget.permanentAddress),
          const SizedBox(
            height: 10,
          ),
          CustomDataRow(
            title1: 'Proof Type',
            value1: widget.proofType,
            title2: widget.proofNo.isNotEmpty ? 'Proof No' : "",
            value2: widget.proofNo,
          ),
          const SizedBox(
            height: 10,
          ),
          Visibility(
            visible: widget.sourceOfAddress.toLowerCase().contains("manual") &&
                widget.perproofdateofisu.isNotEmpty,
            child: Column(
              children: [
                CustomDataRow(
                  title1: 'Date of Issue',
                  value1: widget.perproofdateofisu,
                  title2: widget.perproofplaceofisu.isNotEmpty
                      ? 'Place of Issue'
                      : "",
                  value2: widget.perproofplaceofisu,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Visibility(
            visible: widget.perproofexpirydate.isNotEmpty,
            child: Column(
              children: [
                CustomDataRow(
                  title1: 'Date of Expire',
                  value1: widget.perproofexpirydate,
                  title2: "",
                  value2: "",
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Visibility(
            visible: widget.proofFileId1.isNotEmpty,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Text(
                      "Preview Address Proof File${widget.proofFileId2.isNotEmpty ? "1" : ""}",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    onTap: () {
                      preViewFile(
                        id: widget.proofFileId1,
                        title:
                            "Address_Proof_File${widget.proofFileId2.isNotEmpty ? "1" : ""}",
                      );
                    },
                  ),
                ),
                Visibility(
                    visible: widget.proofFileId2.isNotEmpty,
                    child: const SizedBox(width: 10.0)),
                Visibility(
                  visible: widget.proofFileId2.isNotEmpty,
                  child: Expanded(
                    child: InkWell(
                      child: Text(
                        "Preview Address Proof File2",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onTap: () {
                        preViewFile(
                          id: widget.proofFileId2,
                          title: "Address_Proof_File2",
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CustomColumnWidget(
              title: widget.addressType2.isNotEmpty
                  ? widget.addressType2
                  : 'Correspondence Address',
              value: widget.correspondenceAddress),
          const SizedBox(
            height: 10,
          ),
          Visibility(
            visible: widget.proofType.isNotEmpty,
            child: Column(
              children: [
                CustomDataRow(
                  title1: 'Proof Type',
                  value1: widget.proofType,
                  title2: widget.proofNo.isNotEmpty ? 'Proof No' : "",
                  value2: widget.proofNo,
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible:
                      widget.sourceOfAddress.toLowerCase().contains("manual") &&
                          widget.coradrsproofisudate.isNotEmpty,
                  child: Column(
                    children: [
                      CustomDataRow(
                        title1: 'Date of Issue',
                        value1: widget.coradrsproofisudate,
                        title2: widget.coradrsproofplaceisu.isNotEmpty
                            ? 'Place of Issue'
                            : "",
                        value2: widget.coradrsproofplaceisu,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.corproofexpirydate.isNotEmpty,
                  child: Column(
                    children: [
                      CustomDataRow(
                        title1: 'Date of Expire',
                        value1: widget.corproofexpirydate,
                        title2: "",
                        value2: "",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.cordocid1.isNotEmpty,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          child: Text(
                            "Preview Address Proof File${widget.cordocid1.isNotEmpty ? "1" : ""}",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          onTap: () {
                            preViewFile(
                              id: widget.cordocid1,
                              title:
                                  "Address_Proof_File${widget.cordocid1.isNotEmpty ? "1" : ""}",
                            );
                          },
                        ),
                      ),
                      Visibility(
                          visible: widget.cordocid2.isNotEmpty,
                          child: const SizedBox(width: 10.0)),
                      Visibility(
                        visible: widget.cordocid2.isNotEmpty,
                        child: Expanded(
                          child: InkWell(
                            child: Text(
                              "Preview Address Proof File2",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            onTap: () {
                              preViewFile(
                                id: widget.cordocid2,
                                title: "Address_Proof_File2",
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
