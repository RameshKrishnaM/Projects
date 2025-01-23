import 'dart:convert';

ReviewModel reviewModelFromJson(String str) =>
    ReviewModel.fromJson(json.decode(str));

String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

class ReviewModel {
  Basicinfo basicinfo;
  Address address;
  Bank bank;
  Personal personal;
  List<Nominearr> nominearr;
  Ipv ipv;
  Signeddoc signeddoc;
  String status;
  String cdslflag;

  ReviewModel({
    required this.basicinfo,
    required this.address,
    required this.bank,
    required this.personal,
    required this.nominearr,
    required this.ipv,
    required this.signeddoc,
    required this.status,
    required this.cdslflag,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        basicinfo: Basicinfo.fromJson(json["basicinfo"]),
        address: Address.fromJson(json["address"]),
        bank: Bank.fromJson(json["bank"]),
        personal: Personal.fromJson(json["personal"]),
        nominearr: json["nominearr"] == null
            ? []
            : List<Nominearr>.from(
                json["nominearr"].map((x) => Nominearr.fromJson(x))),
        ipv: Ipv.fromJson(json["ipv"]),
        signeddoc: Signeddoc.fromJson(json["signeddoc"]),
        status: json["status"] ?? "",
        cdslflag: json["cdslflag"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "basicinfo": basicinfo.toJson(),
        "address": address.toJson(),
        "bank": bank.toJson(),
        "personal": personal.toJson(),
        "nominearr": List<dynamic>.from(nominearr.map((x) => x.toJson())),
        "ipv": ipv.toJson(),
        "signeddoc": signeddoc.toJson(),
        "status": status,
        "cdslflag": cdslflag,
      };
}

class Address {
  String sourceofaddress;
  String addresstype1;
  String peraddress1;
  String peraddress2;
  String peraddress3;
  String percity;
  String perpincode;
  String perstate;
  String percountry;
  String proofofaddresstype;
  String perdate;
  String perproofno;
  String perpalceofissue;
  String perproofexpirydate;
  String perdocname1;
  String docid1;
  String perdocname2;
  String docid2;
  String addresstype2;
  String coraddress1;
  String coraddress2;
  String coraddress3;
  String corcity;
  String corpincode;
  String corstate;
  String corcountry;
  String coradrsproofname;
  String coradrsproofno;
  String coradrsproofplaceisu;
  String coradrsproofisudate;
  String corproofexpirydate;
  String cordocid1;
  String cordocid2;

  Address({
    required this.sourceofaddress,
    required this.addresstype1,
    required this.peraddress1,
    required this.peraddress2,
    required this.peraddress3,
    required this.percity,
    required this.perpincode,
    required this.perstate,
    required this.percountry,
    required this.proofofaddresstype,
    required this.perdate,
    required this.perproofno,
    required this.perpalceofissue,
    required this.perproofexpirydate,
    required this.perdocname1,
    required this.docid1,
    required this.perdocname2,
    required this.docid2,
    required this.addresstype2,
    required this.coraddress1,
    required this.coraddress2,
    required this.coraddress3,
    required this.corcity,
    required this.corpincode,
    required this.corstate,
    required this.corcountry,
    required this.coradrsproofname,
    required this.coradrsproofno,
    required this.coradrsproofplaceisu,
    required this.coradrsproofisudate,
    required this.corproofexpirydate,
    required this.cordocid1,
    required this.cordocid2,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        sourceofaddress: json["sourceofaddress"] ?? "",
        addresstype1: json["addresstype1"] ?? "",
        peraddress1: json["peraddress1"] ?? "",
        peraddress2: json["peraddress2"] ?? "",
        peraddress3: json["peraddress3"] ?? "",
        percity: json["percity"] ?? "",
        perpincode: json["perpincode"] ?? "",
        perstate: json["perstate"] ?? "",
        percountry: json["percountry"] ?? "",
        proofofaddresstype: json["proofofaddresstype"] ?? "",
        perdate: json["perdate"] ?? "",
        perproofno: json["perproofno"] ?? "",
        perpalceofissue: json["perpalceofissue"] ?? "",
        perproofexpirydate: json["perproofexpirydate"] ?? "",
        perdocname1: json["perdocname1"] ?? "",
        docid1: json["docid1"] ?? "",
        perdocname2: json["perdocname2"] ?? "",
        docid2: json["docid2"] ?? "",
        addresstype2: json["addresstype2"] ?? "",
        coraddress1: json["coraddress1"] ?? "",
        coraddress2: json["coraddress2"] ?? "",
        coraddress3: json["coraddress3"] ?? "",
        corcity: json["corcity"] ?? "",
        corpincode: json["corpincode"] ?? "",
        corstate: json["corstate"] ?? "",
        corcountry: json["corcountry"] ?? "",
        coradrsproofname: json["coradrsproofname"] ?? "",
        coradrsproofno: json["coradrsproofno"] ?? "",
        coradrsproofplaceisu: json["coradrsproofplaceisu"] ?? "",
        coradrsproofisudate: json["coradrsproofisudate"] ?? "",
        corproofexpirydate: json["corproofexpirydate"] ?? "",
        cordocid1: json["cordocid1"] ?? "",
        cordocid2: json["cordocid2"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "sourceofaddress": sourceofaddress,
        "addresstype1": addresstype1,
        "peraddress1": peraddress1,
        "peraddress2": peraddress2,
        "peraddress3": peraddress3,
        "percity": percity,
        "perpincode": perpincode,
        "perstate": perstate,
        "percountry": percountry,
        "proofofaddresstype": proofofaddresstype,
        "perdate": perdate,
        "perproofno": perproofno,
        "perpalceofissue": perpalceofissue,
        "perdocname1": perdocname1,
        "docid1": docid1,
        "perdocname2": perdocname2,
        "docid2": docid2,
        "addresstype2": addresstype2,
        "coraddress1": coraddress1,
        "coraddress2": coraddress2,
        "coraddress3": coraddress3,
        "corcity": corcity,
        "corpincode": corpincode,
        "corstate": corstate,
        "corcountry": corcountry,
      };
}

class Bank {
  String accountno;
  String ifsc;
  String micr;
  String bankname;
  String bankbranch;
  String bankaddress;
  String bankprooftype;
  String acctype;
  String pennydrop;
  String pennydropstatus;
  String nameaspennydrop;

  Bank({
    required this.accountno,
    required this.ifsc,
    required this.micr,
    required this.bankname,
    required this.bankbranch,
    required this.bankaddress,
    required this.bankprooftype,
    required this.acctype,
    required this.pennydrop,
    required this.pennydropstatus,
    required this.nameaspennydrop,
  });

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
        accountno: json["accountno"] ?? "",
        ifsc: json["ifsc"] ?? "",
        micr: json["micr"] ?? "",
        bankname: json["bankname"] ?? "",
        bankbranch: json["bankbranch"] ?? "",
        bankaddress: json["bankaddress"] ?? "",
        bankprooftype: json["bankprooftype"] ?? "",
        acctype: json["acctype"] ?? "",
        pennydrop: json["pennydrop"] ?? "",
        pennydropstatus: json["pennydropstatus"] ?? "",
        nameaspennydrop: json["nameaspennydrop"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "accountno": accountno,
        "ifsc": ifsc,
        "micr": micr,
        "bankname": bankname,
        "bankbranch": bankbranch,
        "bankaddress": bankaddress,
        "bankprooftype": bankprooftype,
        "acctype": acctype,
        "pennydrop": pennydrop,
        "pennydropstatus": pennydropstatus,
        "nameaspennydrop": nameaspennydrop,
      };
}

class Basicinfo {
  String givenname;
  String nameasperpan;
  String panno;
  String dob;
  String mobileno;
  String emailid;
  String linkedaadhar;
  String dateofsubmit;

  Basicinfo({
    required this.givenname,
    required this.nameasperpan,
    required this.panno,
    required this.dob,
    required this.mobileno,
    required this.emailid,
    required this.linkedaadhar,
    required this.dateofsubmit,
  });

  factory Basicinfo.fromJson(Map<String, dynamic> json) => Basicinfo(
        givenname: json["givenname"] ?? "",
        nameasperpan: json["nameasperpan"] ?? "",
        panno: json["panno"] ?? "",
        dob: json["dob"] ?? "",
        mobileno: json["mobileno"] ?? "",
        emailid: json["emailid"] ?? "",
        linkedaadhar: json["linkedaadhar"]!,
        dateofsubmit: json["dateofsubmit"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "givenname": givenname,
        "nameasperpan": nameasperpan,
        "panno": panno,
        "dob": dob,
        "mobileno": mobileno,
        "emailid": emailid,
        "linkedaadhar": linkedaadhar,
        "dateofsubmit": dateofsubmit,
      };
}

class Dematandservices {
  Services services;
  String dpscheme;
  String dis;
  String edis;

  Dematandservices({
    required this.services,
    required this.dpscheme,
    required this.dis,
    required this.edis,
  });

  factory Dematandservices.fromJson(Map<String, dynamic> json) =>
      Dematandservices(
        services: Services.fromJson(json["services"]),
        dpscheme: json["dpscheme"],
        dis: json["dis"],
        edis: json["edis"]!,
      );

  Map<String, dynamic> toJson() => {
        "services": services.toJson(),
        "dpscheme": dpscheme,
        "dis": dis,
        "edis": edis,
      };
}

class Services {
  String status;
  List<String> serveHead;
  List<List<String>> serveData;
  List<Datum> serveDbData;
  List<String> brokhead;
  List<List<String>> brokdata;
  List<Datum> brokdbdata;

  Services({
    required this.status,
    required this.serveHead,
    required this.serveData,
    required this.serveDbData,
    required this.brokhead,
    required this.brokdata,
    required this.brokdbdata,
  });

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        status: json["status"],
        serveHead: List<String>.from(json["serveHead"].map((x) => x)),
        serveData: List<List<String>>.from(
            json["serveData"].map((x) => List<String>.from(x.map((x) => x)))),
        serveDbData:
            List<Datum>.from(json["serveDbData"].map((x) => Datum.fromJson(x))),
        brokhead: List<String>.from(json["brokhead"].map((x) => x)),
        brokdata: List<List<String>>.from(
            json["brokdata"].map((x) => List<String>.from(x.map((x) => x)))),
        brokdbdata:
            List<Datum>.from(json["brokdbdata"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "serveHead": List<dynamic>.from(serveHead.map((x) => x)),
        "serveData": List<dynamic>.from(
            serveData.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "serveDbData": List<dynamic>.from(serveDbData.map((x) => x.toJson())),
        "brokhead": List<dynamic>.from(brokhead.map((x) => x)),
        "brokdata": List<dynamic>.from(
            brokdata.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "brokdbdata": List<dynamic>.from(brokdbdata.map((x) => x.toJson())),
      };
}

class Datum {
  String id;
  String rowhead;
  String colhead;
  String values;
  String userselect;

  Datum({
    required this.id,
    required this.rowhead,
    required this.colhead,
    required this.values,
    required this.userselect,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        rowhead: json["rowhead"],
        colhead: json["colhead"],
        values: json["values"],
        userselect: json["userselect"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rowhead": rowhead,
        "colhead": colhead,
        "values": values,
        "userselect": userselect,
      };
}

class Ipv {
  String ipvotp;
  String imagedocid;
  String videodocid;
  String signatureid;
  String latitude;
  String longitude;
  String timestamp;

  Ipv({
    required this.signatureid,
    required this.ipvotp,
    required this.imagedocid,
    required this.videodocid,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory Ipv.fromJson(Map<String, dynamic> json) => Ipv(
        signatureid: json["signatureId"] ?? "",
        ipvotp: json["ipvotp"] ?? "",
        imagedocid: json["imagedocid"] ?? "",
        videodocid: json["videodocid"] ?? "",
        latitude: json["latitude"] ?? "",
        longitude: json["longitude"] ?? "",
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "ipvotp": ipvotp,
        "imagedocid": imagedocid,
        "videodocid": videodocid,
        "signatureId": signatureid,
        "latitude": latitude,
        "longitude": longitude,
        "timestamp": timestamp,
      };
}

class Nominearr {
  String nomineename;
  String nomineerelationship;
  String nomineeshare;
  String nomineedob;
  String nomineeaddress1;
  String nomineeaddress2;
  String nomineeaddress3;
  String nomineecity;
  String nomineestate;
  String nomineecountry;
  String nomineepincode;
  String nomineemobileno;
  String nomineeemailid;
  String nomineeproofofidentity;
  String nomineeproofnumber;
  String nomineefileuploaddocids;
  String nomineefilename;
  String guardianname;
  String guardianrelationship;
  String guardianaddress1;
  String guardianaddress2;
  String guardianaddress3;
  String guardiancity;
  String guardianstate;
  String guardiancountry;
  String guardianpincode;
  String guardianmobileno;
  String guardianemailid;
  String guardianproofofidentity;
  String guardianproofnumber;
  String guardianfileuploaddocids;
  String guardianfilename;
  String nomineeplaceofissue;
  String nomineeproofdateofissue;
  String nomineeproofexpriydate;
  String guardianplaceofissue;
  String guardianproofdateofissue;
  String guardianproofexpriydate;
  String nomineetitle;
  String guardiantitle;

  Nominearr(
      {required this.nomineename,
      required this.nomineerelationship,
      required this.nomineeshare,
      required this.nomineedob,
      required this.nomineeaddress1,
      required this.nomineeaddress2,
      required this.nomineeaddress3,
      required this.nomineecity,
      required this.nomineestate,
      required this.nomineecountry,
      required this.nomineepincode,
      required this.nomineemobileno,
      required this.nomineeemailid,
      required this.nomineeproofofidentity,
      required this.nomineeproofnumber,
      required this.nomineefileuploaddocids,
      required this.nomineefilename,
      required this.guardianname,
      required this.guardianrelationship,
      required this.guardianaddress1,
      required this.guardianaddress2,
      required this.guardianaddress3,
      required this.guardiancity,
      required this.guardianstate,
      required this.guardiancountry,
      required this.guardianpincode,
      required this.guardianmobileno,
      required this.guardianemailid,
      required this.guardianproofofidentity,
      required this.guardianproofnumber,
      required this.guardianfileuploaddocids,
      required this.guardianfilename,
      required this.nomineeplaceofissue,
      required this.nomineeproofdateofissue,
      required this.nomineeproofexpriydate,
      required this.guardianplaceofissue,
      required this.guardianproofdateofissue,
      required this.guardianproofexpriydate,
      required this.nomineetitle,
      required this.guardiantitle});

  factory Nominearr.fromJson(Map<String, dynamic> json) => Nominearr(
      nomineename: json["nomineename"] ?? "",
      nomineerelationship: json["nomineerelationship"] ?? "",
      nomineeshare: json["nomineeshare"] ?? "",
      nomineedob: json["nomineedob"] ?? "",
      nomineeaddress1: json["nomineeaddress1"] ?? "",
      nomineeaddress2: json["nomineeaddress2"] ?? "",
      nomineeaddress3: json["nomineeaddress3"] ?? "",
      nomineecity: json["nomineecity"] ?? "",
      nomineestate: json["nomineestate"] ?? "",
      nomineecountry: json["nomineecountry"] ?? "",
      nomineepincode: json["nomineepincode"] ?? "",
      nomineemobileno: json["nomineemobileno"] ?? "",
      nomineeemailid: json["nomineeemailid"] ?? "",
      nomineeproofofidentity: json["nomineeproofofidentity"] ?? "",
      nomineeproofnumber: json["nomineeproofnumber"] ?? "",
      nomineefileuploaddocids: json["nomineefileuploaddocids"] ?? "",
      nomineefilename: json["nomineefilename"] ?? "",
      guardianname: json["guardianname"] ?? "",
      guardianrelationship: json["guardianrelationship"] ?? "",
      guardianaddress1: json["guardianaddress1"] ?? "",
      guardianaddress2: json["guardianaddress2"] ?? "",
      guardianaddress3: json["guardianaddress3"] ?? "",
      guardiancity: json["guardiancity"] ?? "",
      guardianstate: json["guardianstate"] ?? "",
      guardiancountry: json["guardiancountry"] ?? "",
      guardianpincode: json["guardianpincode"] ?? "",
      guardianmobileno: json["guardianmobileno"] ?? "",
      guardianemailid: json["guardianemailid"] ?? "",
      guardianproofofidentity: json["guardianproofofidentity"] ?? "",
      guardianproofnumber: json["guardianproofnumber"] ?? "",
      guardianfileuploaddocids: json["guardianfileuploaddocids"] ?? "",
      guardianfilename: json["guardianfilename"] ?? "",
      nomineeplaceofissue: json["nomineeplaceofissue"] ?? "",
      nomineeproofdateofissue: json["nomineeproofdateofissue"] ?? "",
      nomineeproofexpriydate: json["nomineeproofexpriydate"] ?? "",
      guardianplaceofissue: json["guardianplaceofissue"] ?? "",
      guardianproofdateofissue: json["guardianproofdateofissue"] ?? "",
      guardianproofexpriydate: json["guardianproofexpriydate"] ?? "",
      nomineetitle: json["nomineetitle"] ?? "",
      guardiantitle: json["guardiantitle"] ?? "");

  Map<String, dynamic> toJson() => {
        "nomineename": nomineename,
        "nomineerelationship": nomineerelationship,
        "nomineeshare": nomineeshare,
        "nomineedob": nomineedob,
        "nomineeaddress1": nomineeaddress1,
        "nomineeaddress2": nomineeaddress2,
        "nomineeaddress3": nomineeaddress3,
        "nomineecity": nomineecity,
        "nomineestate": nomineestate,
        "nomineecountry": nomineecountry,
        "nomineepincode": nomineepincode,
        "nomineemobileno": nomineemobileno,
        "nomineeemailid": nomineeemailid,
        "nomineeproofofidentity": nomineeproofofidentity,
        "nomineeproofnumber": nomineeproofnumber,
        "nomineefileuploaddocids": nomineefileuploaddocids,
        "nomineefilename": nomineefilename,
        "guardianname": guardianname,
        "guardianrelationship": guardianrelationship,
        "guardianaddress1": guardianaddress1,
        "guardianaddress2": guardianaddress2,
        "guardianaddress3": guardianaddress3,
        "guardiancity": guardiancity,
        "guardianstate": guardianstate,
        "guardiancountry": guardiancountry,
        "guardianpincode": guardianpincode,
        "guardianmobileno": guardianmobileno,
        "guardianemailid": guardianemailid,
        "guardianproofofidentity": guardianproofofidentity,
        "guardianproofnumber": guardianproofnumber,
        "guardianfileuploaddocids": guardianfileuploaddocids,
        "guardianfilename": guardianfilename,
        "nomineeplaceofissue": nomineeplaceofissue,
        "nomineeproofdateofissue": nomineeproofdateofissue,
        "nomineeproofexpriydate": nomineeproofexpriydate,
        "guardianplaceofissue": guardianplaceofissue,
        "guardianproofdateofissue": guardianproofdateofissue,
        "guardianproofexpriydate": guardianproofexpriydate,
        "nomineetitle": nomineetitle,
        "guardiantitle": guardiantitle
      };
}

class Personal {
  String fathername;
  String mothername;
  String gender;
  String mobileno;
  String mobilenobelongsto;
  String emailid;
  String emailidbelongsto;
  String occupation;
  String maritalstatus;
  String annualincome;
  String tradingexposed;
  String educationqualification;
  String politicallyexposed;
  String educationothers;
  String otheroccupation;
  String emailownername;
  String phoneownername;
  String nominee;
  String pastActions;
  String dealSubBroker;
  String pastActionsDesc;
  String dealSubBrokerDesc;
  String fatcaDeclaration;
  String fatcaTaxExempt;
  String fatcaTaxExemptReason;
  String residenceCountry;
  String taxIdendificationNumber;
  String placeofBirth;
  String countryofBirth;
  String foreignAddress1;
  String foreignAddress2;
  String foreignAddress3;
  String foreignCity;
  String foreignCountry;
  String foreignState;
  String foreignPincode;

  Personal(
      {required this.fathername,
      required this.mothername,
      required this.gender,
      required this.mobileno,
      required this.mobilenobelongsto,
      required this.emailid,
      required this.emailidbelongsto,
      required this.occupation,
      required this.maritalstatus,
      required this.annualincome,
      required this.tradingexposed,
      required this.educationqualification,
      required this.politicallyexposed,
      required this.educationothers,
      required this.otheroccupation,
      required this.emailownername,
      required this.phoneownername,
      required this.nominee,
      required this.pastActions,
      required this.dealSubBroker,
      required this.pastActionsDesc,
      required this.dealSubBrokerDesc,
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

  factory Personal.fromJson(Map<String, dynamic> json) => Personal(
        fathername: json["fathername"] ?? "",
        mothername: json["mothername"] ?? "",
        gender: json["gender"] ?? "",
        mobileno: json["mobileno"] ?? "",
        mobilenobelongsto: json["mobilenobelongsto"] ?? "",
        emailid: json["emailid"] ?? "",
        emailidbelongsto: json["emailidbelongsto"] ?? "",
        occupation: json["occupation"] ?? "",
        maritalstatus: json["maritalstatus"] ?? "",
        annualincome: json["annualincome"] ?? "",
        tradingexposed: json["tradingexposed"] ?? "",
        educationqualification: json["educationqualification"] ?? "",
        politicallyexposed: json["politicallyexposed"]!,
        educationothers: json["educationothers"] ?? "",
        otheroccupation: json["otheroccupation"] ?? "",
        emailownername: json["emailownername"] ?? "",
        phoneownername: json["phoneownername"] ?? "",
        nominee: json["nominee"],
        pastActions: json["pastActions"] ?? "",
        dealSubBroker: json["dealSubBroker"] ?? "",
        pastActionsDesc: json["pastActionsDesc"] ?? "",
        dealSubBrokerDesc: json["dealSubBrokerDesc"] ?? "",
        fatcaDeclaration: json["fatcaDeclaration"] ?? "",
        fatcaTaxExempt: json["fatcaTaxExempt"] ?? "",
        fatcaTaxExemptReason: json["fatcaTaxExemptReason"] ?? "",
        residenceCountry: json["residenceCountry"] ?? "",
        taxIdendificationNumber: json["taxIdendificationNumber"] ?? "",
        placeofBirth: json["placeofBirth"] ?? "",
        countryofBirth: json["countryofBirth"] ?? "",
        foreignAddress1: json["foreignAddress1"] ?? "",
        foreignAddress2: json["foreignAddress2"] ?? "",
        foreignAddress3: json["foreignAddress3"] ?? "",
        foreignCity: json["foreignCity"] ?? "",
        foreignCountry: json["foreignCountry"] ?? "",
        foreignState: json["foreignState"] ?? "",
        foreignPincode: json["foreignPincode"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "fathername": fathername,
        "mothername": mothername,
        "gender": gender,
        "mobileno": mobileno,
        "mobilenobelongsto": mobilenobelongsto,
        "emailid": emailid,
        "emailidbelongsto": emailidbelongsto,
        "occupation": occupation,
        "maritalstatus": maritalstatus,
        "annualincome": annualincome,
        "tradingexposed": tradingexposed,
        "educationqualification": educationqualification,
        "politicallyexposed": politicallyexposed,
        "educationothers": educationothers,
        "otheroccupation": otheroccupation,
        "emailownername": emailownername,
        "phoneownername": phoneownername,
        "nominee": nominee,
      };
}

class Signeddoc {
  String signiid;
  String incomeid;
  String panid;
  String signflag;
  String incometype;
  String checkleafid;
  String signimagename;
  String incomeimagename;
  String panimagename;
  String checkleafname;

  Signeddoc({
    required this.signflag,
    required this.signiid,
    required this.incomeid,
    required this.panid,
    required this.incometype,
    required this.checkleafid,
    required this.signimagename,
    required this.incomeimagename,
    required this.panimagename,
    required this.checkleafname,
  });

  factory Signeddoc.fromJson(Map<String, dynamic> json) => Signeddoc(
        signiid: json["signiid"] ?? "",
        signflag: json["signflag"] ?? "",
        incomeid: json["incomeid"] ?? "",
        panid: json["panid"] ?? "",
        incometype: json["incometype"] ?? "",
        checkleafid: json["checkleafid"] ?? "",
        signimagename: json["signimagename"] ?? "",
        incomeimagename: json["incomeimagename"] ?? "",
        panimagename: json["panimagename"] ?? "",
        checkleafname: json["checkleafname"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "signiid": signiid,
        "incomeid": incomeid,
        "panid": panid,
        "signflag": signflag,
        "incometype": incometype,
        "checkleafid": checkleafid,
        "signimagename": signimagename,
        "incomeimagename": incomeimagename,
        "panimagename": panimagename,
        "checkleafname": checkleafname,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
