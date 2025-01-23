import 'package:ekycold/detailspage.dart';
import 'package:ekycold/equity.dart';
import 'package:ekycold/laststep.dart';
import 'package:ekycold/widgets/custom_button_small.dart';
import 'package:flutter/material.dart';

class Esign extends StatefulWidget {
  const Esign({super.key});

  @override
  State<Esign> createState() => _EsignState();
}

class _EsignState extends State<Esign> {
  List<Widget> pages = [
    const LastStep(),
    const Equity(),
    const Details(),
  ];
  final controller = PageController();
  // final controller = CarouselSliderController();
  int numberOfPages = 3;
  int? currentPage = 0;

  bool isEsignButtonClicked = true;

  void goToNextPage() {
    if (currentPage! < numberOfPages) {
      if (currentPage! >= 0 || (currentPage == 1 && isEsignButtonClicked)) {
        controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.bounceInOut,
        );
        currentPage = currentPage! + 1;
        setState(() {});
      }
    }
  }

  void goToPreviousPage() {
    if (currentPage! > 0) {
      controller.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceInOut,
      );
      currentPage = currentPage! - 1;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            SizedBox(
              height: 760,
              child: PageView.builder(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: numberOfPages,
                onPageChanged: (index) {
                  currentPage = index;
                },
                itemBuilder: (context, index) => pages[index],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: (currentPage! >= 0
                      // && currentPage! < pages.length - 1
                      ),
                  child: CustomButtonSmall(
                    onPressed: (currentPage! > 0)
                        ? goToPreviousPage
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text('Back'),
                  ),
                ),
                Visibility(
                  visible: currentPage! < pages.length,
                  child: CustomButtonSmall(
                    onPressed: currentPage == pages.length - 1
                        ? () {
                            //Navigate to Next Page
                          }
                        : goToNextPage,
                    child: Text(
                        currentPage == pages.length - 1 ? 'Finish' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
