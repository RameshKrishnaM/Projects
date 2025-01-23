import '../Cookies/HttpClient.dart';
import 'package:flutter/material.dart';

import '../Cookies/cookies.dart';
import '../Model/Application_Statu.dart';
import 'custom_button.dart';

class FinalColumn extends StatefulWidget {
  const FinalColumn({Key? key, required this.context}) : super(key: key);
  final BuildContext context;
  @override
  // ignore: library_private_types_in_public_api
  _YourCustomColumnState createState() => _YourCustomColumnState();
}

class _YourCustomColumnState extends State<FinalColumn> {
  bool isStatusLoaded = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  ApplicationModel? applicationModel;
  fetchData() async {
    try {
      var response = await CustomHttpClient.get("api/Get_Form_Status", context);
      if (response.statusCode == 200) {
        applicationModel = applicationModelFromJson(response.body);
        isStatusLoaded = false;
        if (mounted) {
          setState(() {});
        }
      } else {
        showSnackbar("Error: ${response.statusCode}");
      }
    } catch (error) {
      showSnackbar("Error: $error");
    }
  }

  void showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Text(
            'You have succecssfully completed the account opening process',
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(fontSize: 18.0, height: 1),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/endSymbol.png',
              width: 52.0,
              height: 52.0,
            )
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45.0),
          child: Text(
            'You will receive 3 mails with your trading and Demat account Creditials Shortly',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontSize: 12.0, height: 1, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.020,
        ),
        CustomButton(
          buttonFunc: () {},
          buttonText: 'Application Download',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.020,
        ),
        Text(
          'User Details',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.w600, fontSize: 18.0),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 25.0, left: 30.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: const Color.fromRGBO(9, 101, 218, 1),
                  width: 1.0,
                )),
            padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 15.0),
            child: Column(children: [
              details(
                  context,
                  'Email ID',
                  !isStatusLoaded
                      ? applicationModel!.email
                      : 'mukesh@gmail.com'),
              const SizedBox(
                height: 10.0,
              ),
              details(context, 'Mobile No.',
                  !isStatusLoaded ? applicationModel!.mobil : '8942652623'),
              const SizedBox(
                height: 10.0,
              ),
              details(
                  context,
                  'Application No.',
                  !isStatusLoaded
                      ? applicationModel!.applicationNo
                      : '458624585'),
              const SizedBox(
                height: 10.0,
              ),
              details(
                  context,
                  'Application Status',
                  !isStatusLoaded
                      ? applicationModel!.applicationStatus
                      : 'Success'),
            ]),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Container(
          width: double.infinity,
          color: const Color.fromRGBO(9, 101, 218, 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
          child: Center(
            child: Text(
              'You can try our app with guest login in the mean time',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontSize: 12.0,
                  height: 1,
                  color: const Color.fromRGBO(255, 255, 255, 1)),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Container(
          width: 136.80,
          height: 40.0,
          margin: EdgeInsets.only(
            bottom: 10.0,
            top: MediaQuery.of(context).size.height * 0.05,
          ),
          decoration: ShapeDecoration(
            color: const Color(0xFF0965DA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.70),
            ),
          ),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll(Color.fromRGBO(9, 101, 218, 1)),
            ),
            onPressed: () {},
            child: Center(
              child: Text(
                'Guest Login',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 17.0,
                    height: 1,
                    color: const Color.fromRGBO(255, 255, 255, 1)),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.020,
        ),
      ],
    );
  }
}

Widget details(BuildContext context, String txt1, String txt2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          txt1,
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(fontSize: 16.0, height: 1),
        ),
      ),
      Text(
        ':',
        style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(fontSize: 16.0, height: 1),
        // textAlign: TextAlign.center,
      ),
      const SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: Text(
          txt2,
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(fontSize: 12.0, height: 1, fontWeight: FontWeight.w400),
        ),
      ),
    ],
  );
}
