import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:project2/congrats.dart';
import 'package:project2/details.dart';
import 'package:project2/equity.dart';
import 'package:project2/lastStep.dart';
// import 'package:provider/provider.dart';

class PageSwap extends ChangeNotifier {
  List<Widget> pages = [Details(), LastStep(), Equity(), CongratsPage()];
  final controller = CarouselSliderController();
  bool isButtonEnabled = true;
  int numberOfPages = 4;
  int? currentPage = 0;

  bool isEsignButtonClicked = true;

  void goToNextPage() {
    if (currentPage! < numberOfPages) {
      if (currentPage! >= 0 || (currentPage == 1 && isEsignButtonClicked)) {
        controller.nextPage();
        currentPage = currentPage! + 1;
        notifyListeners();
      }
    }
  }

  void goToPreviousPage() {
    if (currentPage! > 0) {
      controller.previousPage();
      currentPage = currentPage! - 1;
      notifyListeners();
    }
  }

  void esignButtonClicked() {
    isButtonEnabled = true;
    isEsignButtonClicked = true;
    notifyListeners();
  }
}
