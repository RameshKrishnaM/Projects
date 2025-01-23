import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/provider.dart';
import '../../../utils/colors.dart';
import '../Mf_Bottom_Sheet_Widgets/mfcustomPaymentBS.dart';

showSugestionBottomSheet({
  required BuildContext newContext,
  required String isin,
  num? amount,
  int? id,
}) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
    context: newContext,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      mfInvestBottomSheet(
                          context: newContext, isin: isin, type: 'cart');
                    },
                    child: Container(
                      width: 80,
                      height: 70,
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? const Color.fromARGB(255, 230, 228, 228)
                                    .withOpacity(0.1)
                                : Colors.grey.shade200.withOpacity(0.9),
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
                            blurRadius: 20.0,
                            spreadRadius: 10.0,
                          ), //BoxShadow
                          BoxShadow(
                            color: Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
                            offset: const Offset(
                              0.0,
                              0.0,
                            ),
                            blurRadius: 0.0,
                            spreadRadius: 5.0,
                          ), //BoxShadow
                        ],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: appPrimeColor,
                            size: 35,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Add",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      mfInvestBottomSheet(
                          context: newContext,
                          isin: isin,
                          type: 'redeem',
                          amount: amount);
                    },
                    child: Container(
                      width: 80,
                      height: 70,
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? const Color.fromARGB(255, 230, 228, 228)
                                    .withOpacity(0.1)
                                : Colors.grey.shade200.withOpacity(0.9),
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
                            blurRadius: 20.0,
                            spreadRadius: 10.0,
                          ), //BoxShadow
                          BoxShadow(
                            color: Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
                            offset: const Offset(
                              0.0,
                              0.0,
                            ),
                            blurRadius: 0.0,
                            spreadRadius: 5.0,
                          ), //BoxShadow
                        ],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            color: appPrimeColor,
                            size: 35,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Redeem",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
    },
  );
}
