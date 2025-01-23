import 'package:ekyc/Screens/congratulation_test.dart';

import '../Screens/account_agreegator.dart';
import '../Screens/address.dart';
import '../Screens/esign_html.dart';
import '../Screens/preview_image.dart';
import '../Screens/manual_entry_address.dart';
import '../Screens/preview_pdf.dart';
import '../Screens/preview_video.dart';
import '../Screens/segmentselection.dart';
import '../Screens/splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../Screens/email.dart';
import '../Screens/email_otp.dart';
import '../Screens/mobile_otp.dart';
import '../Screens/pancard.dart';
import '../Screens/signup.dart';
import 'package:flutter/material.dart';

import '../Screens/ipv.dart';
import '../Screens/congratulation.dart';
import '../Screens/bankscreen.dart';

import '../Screens/digilocker.dart';

import '../Screens/file_upload.dart';
import '../Screens/add_nominee.dart';
import '../Screens/nominee.dart';
import '../Screens/pers_info_screen.dart';
import '../Screens/review.dart';

const splashPage = "/";
const signup = "/Signup";
const mobileOTP = "/mobileOTP";
const email = "/email";
const emailOTP = "/emailOTP";
const panCard = "/Pan-Details";
const address = "/Address-Verification";
const digiLocker = "/digiLocker";
const manualEntry = "/manualEntry";
const bankScreen = "/Bank-Details";
const segmentSelection = "/Demat-Details";
const bankStatement = "/bankStatement";
const persInfo = "/Profile-Details";
const addNominee = "/addNominee";
const nominee = "/Nominee-Details";
const fileUpload = "/Document-Upload";

const review = "/Review-Details";
const congratulation = "/Account-Status";
const congratulationTest = "/Account-Status-Test";
const ipv = "/IPV";
const esignHtml = "/esignHtml";
const previewImage = "/previewImage";
const previewPdf = "/previewpdf";
const previewVideo = "/previewVideo";
const aggregator = "/aggregator";

Map routeNames = {
  signup: "Signup",
  panCard: "PanDetails",
  address: "AddressVerification",
  persInfo: "ProfileDetails",
  nominee: "NomineeDetails",
  bankScreen: "BankDetails",
  segmentSelection: "DematDetails",
  ipv: "IPV",
  fileUpload: "DocumentUpload",
  review: "ReviewDetails",
  congratulation: "AccountStatus"
};
Route<dynamic> controller(RouteSettings settings) {
  Widget page;
  switch (settings.name) {
    case splashPage:
      page = const SplashScreen();
      break;
    case signup:
      page = const Signup();
      break;
    case mobileOTP:
      Map arguments = settings.arguments as Map;
      page = MobileOTP(
        tempUid: arguments["tempUid"],
        encryptMobileNumber: arguments["encrypteval"],
        validateId: arguments["insertedid"],
        name: arguments['name'],
        mobileNumber: arguments["mobileNo"],
        state: arguments["state"],
      );
      break;
    case email:
      Map arguments = settings.arguments as Map;
      page = Email(
        tempUid: arguments["tempUid"],
        name: arguments['name'],
        mobileNumber: arguments["mobileNo"],
        state: arguments["state"],
      );
      break;
    case emailOTP:
      Map arguments = settings.arguments as Map;
      page = EmailOTP(
        tempUid: arguments["tempUid"],
        name: arguments['name'],
        mobileNumber: arguments["mobileNo"],
        email: arguments["email"],
        encryptEmail: arguments["encrypteval"],
        id: arguments["insertedid"],
        state: arguments["state"],
      );
      break;
    case panCard:
      page = const PanCard();
      break;
    case address:
      page = const Address();
    case digiLocker:
      Map? data = settings.arguments != null ? settings.arguments as Map : {};
      page = DigiLocker(
        address: data["address"],
        url: data['url'],
      );
    case manualEntry:
      page = settings.arguments != null
          ? AddressManualEntry(address: settings.arguments as Map)
          : const AddressManualEntry();
    case bankScreen:
      page = const BankScreen();
    case segmentSelection:
      page = const SegmentSelection();
    case aggregator:
      Map? data = settings.arguments != null ? settings.arguments as Map : {};
      page = AccountAggregator(
          mobileNumber: data["mobileno"],
          bankName: data["bankname"],
          accountNumber: data["maskaccount"],
          demantData: data["demantdata"] as Map,
          url: data["url"]);
    case persInfo:
      page = const PersInfoScreen();
    case addNominee:
      Map data = settings.arguments as Map;
      page = AddNomineeForm(
        nom: data["nominee"],
        nomineeDetails: data["nomineeDetails"],
      );
    case nominee:
      page = NomineeDashboard(
          isBack:
              settings.arguments != null ? settings.arguments is bool : null);
    case congratulation:
      page = const Congratulation();
    case congratulationTest:
      page = const CongratulationTest();
    case review:
      page = const Review();
    case ipv:
      page = IPV();
    case fileUpload:
      page = const FileUpload();
    case esignHtml:
      Map data = settings.arguments as Map;
      page = EsignHtml(
          html: data["html"], url: data["url"], routename: data["routeName"]);
    case previewImage:
      Map data = settings.arguments as Map;
      page = ImagePreview(
        title: data["title"],
        data: data["data"],
        fileName: data["fileName"],
      );
    case previewPdf:
      Map data = settings.arguments as Map;
      page = PDFPreview(
        title: data["title"],
        data: data["data"],
        fileName: data["fileName"],
      );
    case previewVideo:
      Map data = settings.arguments as Map;
      page = PreviewVideo(file: data["file"], otp: data["otp"]);
    default:
      throw Exception("Error");
  }
  return PageTransition(child: page, type: PageTransitionType.rightToLeft);
}
