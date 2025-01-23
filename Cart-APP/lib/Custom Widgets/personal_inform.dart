import 'package:flutter/material.dart';

import '../Model/route_model.dart';
import 'custom.dart';
import 'error_message.dart';

class PersonalDetails extends StatefulWidget {
  final String occupation;
  final String income;
  final String maritalStatus;
  final String gender;
  final String fatherName;
  final String motherName;
  final String email;
  final String phone;
  final String experiance;
  final String education;
  final String mailBelongs;
  final String mobileBelongs;
  final String? occuOthers;
  final String? eduOthers;
  final String? emailOwnerName;
  final String? phoneOwnerName;
  final RouteModel? routeDetails;
  final String pastActions;
  final String dealSubBroker;
  final String pastActionsDesc;
  final String dealSubBrokerDesc;
  final String fatcaDeclaration;
  final String fatcaTaxExempt;
  final String fatcaTaxExemptReason;

  final String residenceCountry;
  final String taxIdendificationNumber;
  final String placeofBirth;
  final String countryofBirth;
  final String foreignAddress1;
  final String foreignAddress2;
  final String foreignAddress3;
  final String foreignCity;
  final String foreignCountry;
  final String foreignState;
  final String foreignPincode;
  const PersonalDetails(
      {super.key,
      required this.occupation,
      required this.income,
      required this.maritalStatus,
      required this.gender,
      required this.fatherName,
      required this.motherName,
      required this.email,
      required this.phone,
      required this.experiance,
      required this.education,
      required this.mailBelongs,
      required this.mobileBelongs,
      this.occuOthers,
      this.eduOthers,
      this.emailOwnerName,
      this.phoneOwnerName,
      this.routeDetails,
      required this.pastActionsDesc,
      required this.dealSubBrokerDesc,
      required this.pastActions,
      required this.dealSubBroker,
      required this.fatcaDeclaration,
      required this.fatcaTaxExempt,
      required this.fatcaTaxExemptReason,
      required this.residenceCountry,
      required this.taxIdendificationNumber,
      required this.placeofBirth,
      required this.countryofBirth,
      required this.foreignAddress1,
      required this.foreignAddress2,
      required this.foreignAddress3,
      required this.foreignCity,
      required this.foreignCountry,
      required this.foreignState,
      required this.foreignPincode});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  @override
  Widget build(BuildContext context) {
    return CustomStyledContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErrorMessageContainer(routeDetails: widget.routeDetails),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTitleText(title: 'Email to belongs to :'),
              CustomParagraph1(text: ' ${widget.mailBelongs}'),
              const SizedBox(
                height: 8.0,
              )
            ],
          ),
          if (widget.emailOwnerName != null &&
              widget.emailOwnerName!.isNotEmpty)
            Column(
              children: [
                const SizedBox(
                  height: 5.0,
                ),
                CustomParagraph1(text: 'Name : ${widget.emailOwnerName}'),
              ],
            ),
          const SizedBox(
            height: 3.0,
          ),
          CustomParagraph1(text: 'Email : ${widget.email}'),
          const SizedBox(
            height: 25.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTitleText(title: 'Phone to belongs to :'),
              CustomParagraph1(text: ' ${widget.mobileBelongs}'),
              const SizedBox(
                height: 8.0,
              )
            ],
          ),
          if (widget.phoneOwnerName != null &&
              widget.phoneOwnerName!.isNotEmpty)
            Column(
              children: [
                const SizedBox(
                  height: 5.0,
                ),
                CustomParagraph1(text: 'Name : ${widget.phoneOwnerName}'),
              ],
            ),
          const SizedBox(
            height: 3.0,
          ),
          CustomParagraph1(text: 'Phone : ${widget.phone}'),
          const SizedBox(
            height: 15.0,
          ),
          CustomDataRow(
            title1: 'Marital Status',
            value1: widget.maritalStatus,
            title2: 'Gender',
            value2: widget.gender,
          ),
          const SizedBox(
            height: 15.0,
          ),
          CustomDataRow(
            title1: "Father's Name",
            value1: widget.fatherName,
            title2: widget.motherName.isNotEmpty ? "Mother's Name" : "",
            value2: widget.motherName.isNotEmpty ? widget.motherName : "",
          ),
          const SizedBox(
            height: 25.0,
          ),
          CustomDataRow(
            title1: "Annual Income",
            value1: widget.income,
            title2: "Trading Experiance",
            value2: widget.experiance,
          ),
          const SizedBox(
            height: 15.0,
          ),
          CustomDataRow(
            title1: 'Occupation',
            value1: widget.occupation,
            title2: 'Education Qualification',
            value2: widget.education,
          ),
          const SizedBox(
            height: 15.0,
          ),
          Row(
            children: [
              if (widget.occuOthers != null && widget.occuOthers!.isNotEmpty)
                Expanded(
                  child: CustomColumnWidget(
                    title: 'Other Occupation',
                    value: widget.occuOthers!,
                  ),
                ),
              if (widget.eduOthers != null && widget.eduOthers!.isNotEmpty)
                Expanded(
                  child: CustomColumnWidget(
                    title: 'Other Qualifications',
                    value: widget.eduOthers!,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15.0),
          CustomColumnWidget(
              title:
                  'Details of any action / proceeding initiated / pending / taken by SEBI / Stock Exchange / any other authority against the applicant / constituentor its partners / Promoters / Whole time directors / Authorized persons in-charge of dealing in securities during the last 3 years. ',
              value: widget.pastActions == "Y" ? "Yes" : "No"),
          Visibility(
              visible: widget.pastActions == "Y" &&
                  widget.pastActionsDesc.isNotEmpty,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  CustomColumnWidget(
                      title: 'Past Action Details',
                      value: widget.pastActionsDesc),
                ],
              )),
          const SizedBox(height: 15.0),
          CustomColumnWidget(
              title: "Dealings with sub broker and other stock brokers",
              value: widget.dealSubBroker == "Y" ? "Yes" : "No"),
          Visibility(
              visible: widget.dealSubBroker == "Y" &&
                  widget.dealSubBrokerDesc.isNotEmpty,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  CustomColumnWidget(
                      title: 'Broker/Sub broker Name',
                      value: widget.dealSubBrokerDesc),
                ],
              )),
          const SizedBox(height: 15.0),
          CustomColumnWidget(
              title: "Are you a Tax paying citizen in other country?",
              value: widget.fatcaDeclaration == "Y" ? "Yes" : "No"),
          Visibility(
              visible: widget.fatcaDeclaration == "Y",
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  widget.fatcaTaxExempt == "Y"
                      ? CustomDataRow(
                          title1: "Tax Exempt?",
                          value1: widget.fatcaTaxExempt == "Y" ? "Yes" : "No",
                          title2: "Tax Exempt Reason",
                          value2: widget.fatcaTaxExemptReason,
                        )
                      : CustomColumnWidget(
                          title: "Tax Exempt?",
                          value: widget.fatcaTaxExempt == "Y" ? "Yes" : "No"),
                  const SizedBox(height: 10.0),
                  CustomDataRow(
                    title1: "Country of Jurisdiction of Residence",
                    value1: widget.residenceCountry,
                    title2:
                        "Tax Idendification Number or Equivalent(If issued by jurisdiction)",
                    value2: widget.taxIdendificationNumber,
                  ),
                  const SizedBox(height: 10.0),
                  CustomDataRow(
                    title1: "Place/City of Birth",
                    value1: widget.placeofBirth,
                    title2: "Country of Birth",
                    value2: widget.countryofBirth,
                  ),
                  const SizedBox(height: 10.0),
                  CustomDataRow(
                    title1: "Address 1",
                    value1: widget.foreignAddress1,
                    title2: "Address 2",
                    value2: widget.foreignAddress2,
                  ),
                  const SizedBox(height: 10.0),
                  CustomDataRow(
                    title1: "City",
                    value1: widget.foreignCity,
                    title2: "State",
                    value2: widget.foreignState,
                  ),
                  const SizedBox(height: 10.0),
                  CustomDataRow(
                    title1: "Country",
                    value1: widget.foreignCountry,
                    title2: "Postal / Zip Code",
                    value2: widget.foreignPincode,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
