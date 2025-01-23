import 'package:ekycold/util/colors.dart';
import 'package:ekycold/widgets/background_animated_container.dart';
import 'package:ekycold/widgets/custom_button.dart';
import 'package:ekycold/widgets/custom_button_small.dart';
import 'package:ekycold/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  TextEditingController adrsController = TextEditingController();
  final kycController = PageController();
  String address =
      '59, Vaisiyar Street, Tiyagadurugam, Kallakurichi Taluk, Viluppuram, Tamil Nadu-606206, India';
  int numberOfPages = 3;
  int? currentPage = 0;

  showMyAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: CustomTextFormField(
              controller: adrsController, labelText: 'Address', hintText: ''),
          actions: [
            CustomButton(
              onPressed: () {
                if (adrsController.text.isNotEmpty) {
                  address = adrsController.text;
                }
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Permenent Address',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                WidgetSpan(
                  child: InkWell(
                    onTap: () {
                      showMyAlert();
                    },
                    child: Icon(
                      Icons.edit,
                      color: highlightcolor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            address,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Expanded(child: Text('')),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                kycController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
                // kycController.animateToPage(1,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut);
              },
              child: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            'Correspondence Address',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            '59, Vaisiyar Street, Tiyagadurugam, Kallakurichi Taluk, Viluppuram, Tamil Nadu-606206, India',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Expanded(child: Text('')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  kycController.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                  // kycController.animateToPage(0,
                  //     duration: const Duration(milliseconds: 500),
                  //     curve: Curves.easeInOut);
                },
                child: const Icon(Icons.arrow_back_rounded),
              ),
              InkWell(
                onTap: () {
                  kycController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                  // kycController.animateToPage(2,
                  //     duration: const Duration(milliseconds: 500),
                  //     curve: Curves.easeInOut);
                },
                child: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          )
        ],
      ),
      Column(
        children: [
          Text(
            'proof of Address',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Aadhaar Card',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          Image.asset(
            'assets/images/Aadhaar_Logo.png',
            height: 130,
            color: Colors.grey.shade300,
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButtonSmall(
                  onPressed: () {},
                  child: const Text('Proceed to Digilocker'),
                ),
                CustomButtonSmall(
                  onPressed: () {},
                  child: const Text('Continue with KYC'),
                )
              ],
            ),
          ),
          const Expanded(child: Text('')),
          Align(
            alignment: Alignment.bottomLeft,
            child: InkWell(
              onTap: () {
                kycController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
                // kycController.animateToPage(1,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut);
              },
              child: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ],
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: [
            const BackgroundAnimatedContainer(image: 'kycAddress.png'),
            Text(
              'We Found Your KYC !',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Text(
              'We found your KYC Profile Information from KRA (CVL KRA) as detailed below. Would you like to proceed and continue with this existing profile?',
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 310,
              width: 310,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: PageView.builder(
                allowImplicitScrolling: true,
                controller: kycController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: numberOfPages,
                onPageChanged: (index) {
                  currentPage = index;
                },
                itemBuilder: (context, index) => pages[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*

 Image.asset(
            'assets/images/Aadhaar_Logo.png',
            height: 130,
          ),

 */


 // Text.rich(
            //   TextSpan(
            //     children: [
            //       TextSpan(
            //         text: 'Permenent Address',
            //         style: Theme.of(context).textTheme.bodyLarge,
            //       ),
            //       WidgetSpan(
            //         child: InkWell(
            //           onTap: () {
            //             showMyAlert();
            //           },
            //           child: Icon(
            //             Icons.edit,
            //             color: highlightcolor,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Text(
            //   address,
            //   style: Theme.of(context).textTheme.displayMedium,
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Text(
            //   'Correspondence Address',
            //   style: Theme.of(context).textTheme.bodyLarge,
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Text(
            //   '59, Vaisiyar Street, Tiyagadurugam, Kallakurichi Taluk, Viluppuram, Tamil Nadu-606206, India',
            //   style: Theme.of(context).textTheme.displayMedium,
            // ),