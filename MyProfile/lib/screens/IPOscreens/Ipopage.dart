// ignore_for_file: file_names

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'package:novo/API/APICall.dart';

import 'package:novo/Provider/provider.dart';
import 'package:novo/model/ipoModels/ipoHistoryDetails.dart';
import 'package:novo/model/ipoModels/ipoMasterDetails.dart';
import 'package:novo/screens/IPOscreens/ipoActivePage.dart';
import 'package:novo/screens/IPOscreens/ipohistorypage.dart';
import 'package:novo/utils/colors.dart';

import 'package:provider/provider.dart';

import '../../widgets/NOVO Widgets/Currently_unavailable.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';

class Ipopage extends StatefulWidget {
  const Ipopage({super.key});

  @override
  State<Ipopage> createState() => _IpopageState();
}

class _IpopageState extends State<Ipopage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  IpoMasterDetails? ipoMasterDataApi;
  IpoHistoryDetails? ipoHistoryDataApi;

  bool ipoPageLoading = true;
  bool ipoHistoryLoading = true;

  int _activeIndex = 0;
  @override
  void initState() {
    fetchIPODetailsInAPI(context);
    fetchIPOHistoryDetailsInAPI(context);
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  fetchIPODetailsInAPI(context) async {
    if (await isInternetConnected()) {
      ipoMasterDataApi = await fetchIpoMasterDetails(context: context);
      // ipoHistoryDataApi = await fetchIpoHistoryDetails(context: context);

      if (mounted) {
        setState(() {});
      }
      // setState(() {});
      ipoPageLoading = false;
    } else {
      noInternetConnectAlertDialog(
          context, () => fetchIPODetailsInAPI(context));
    }
  }

  fetchIPOHistoryDetailsInAPI(context) async {
    if (await isInternetConnected()) {
      ipoHistoryDataApi = await fetchIpoHistoryDetails(context: context);

      if (mounted) {
        setState(() {});
      }
      // setState(() {});
      ipoHistoryLoading = false;
    } else {
      noInternetConnectAlertDialog(
          context, () => fetchIPOHistoryDetailsInAPI(context));
    }
  }

  Future<bool> _onWillPop() async {
    if (_activeIndex != 0) {
      _tabController.addListener(() {
        setState(() {
          _activeIndex = _tabController.index;
        });
      });
      setState(() {
        _activeIndex = 0;
      });
      setState(() {});

      return false; // Don't pop the route
    } else {
      return true; // Allow popping the route
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool willPop) => _onWillPop,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // give the tab bar a height [can change hheight to preferred height]
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    Provider.of<NavigationProvider>(context).themeMode ==
                            ThemeMode.dark
                        ? "assets/IPO WNovo Icon.png"
                        : "assets/IPO BNovo Icon.png",
                    width: 25.0,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  const Text(
                    'IPO',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kiro',
                        height: 0.5),
                  ),
                ],
              ),
              const SizedBox(
                height: 12.0,
              ),
              //This is commanted on the Tab bar to BottomNavigation....
              // Container(
              //   height: 35,
              //   decoration: BoxDecoration(
              //     color: Colors.grey[300],
              //     borderRadius: BorderRadius.circular(
              //       15.0,
              //     ),
              //   ),
              //   child: TabBar(
              //     controller: _tabController,
              //     indicator: BoxDecoration(
              //       borderRadius: BorderRadius.circular(
              //         15.0,
              //       ),
              //       color: appPrimeColor,
              //     ),
              //     labelColor: Colors.white,
              //     unselectedLabelColor: Colors.black,
              //     labelStyle: const TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //         fontFamily: 'inter'),
              //     tabs: [
              //       Tab(
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             const Text('Invest'),
              //             // const SizedBox(
              //             //   width: 5.0,
              //             // ),
              //             // ipoPageLoading
              //             //     ? const SizedBox()
              //             //     : ipoMasterDataApi == null ||
              //             //             ipoMasterDataApi!.ipoDetail == null ||
              //             //             ipoMasterDataApi!.investCount
              //             //                 .toString()
              //             //                 .isEmpty ||
              //             //             ipoMasterDataApi!.investCount! < 0 ||
              //             //             ipoMasterDataApi!.investCount! == 0 ||
              //             //             ipoMasterDataApi!.masterFound != 'Y'
              //             //         ? const SizedBox()
              //             //         : TabinfoContainer(
              //             //             tabCount:
              //             //                 '${ipoMasterDataApi!.investCount!}',
              //             //           )
              //           ],
              //         ),
              //       ),
              //       Tab(
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             const Text('Applied'),
              //             // const SizedBox(
              //             //   width: 5.0,
              //             // ),
              //             // ipoPageLoading
              //             //     ? const SizedBox()
              //             //     : ipoHistoryDataApi == null ||
              //             //             ipoHistoryDataApi!.historyDetail ==
              //             //                 null ||
              //             //             ipoHistoryDataApi!.orderCount
              //             //                 .toString()
              //             //                 .isEmpty ||
              //             //             ipoHistoryDataApi!.orderCount! < 0 ||
              //             //             ipoHistoryDataApi!.orderCount! == 0 ||
              //             //             ipoHistoryDataApi!.historyFound != 'Y'
              //             //         ? const SizedBox()
              //             //         : TabinfoContainer(
              //             //             tabCount:
              //             //                 '${ipoHistoryDataApi?.orderCount}',
              //             //           )
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    ipoPageLoading
                        ? const Center(
                            child: LoadingProgress(),
                          )
                        : (ipoMasterDataApi == null ||
                                    ipoMasterDataApi!.masterFound!.isEmpty) ||
                                (!(ipoMasterDataApi!.masterFound == 'Y' ||
                                    ipoMasterDataApi!.masterFound == 'N'))
                            ? CurrentlyUnavailableWidget(
                                refressFunc: () async {
                                  await fetchIPODetailsInAPI(context);
                                },
                              )
                            : IpoScreen(
                                ipoMasterDetailsData: ipoMasterDataApi!),

                    //History tab
                    ipoHistoryLoading
                        ? const Center(
                            child: LoadingProgress(),
                          )
                        : (ipoHistoryDataApi == null ||
                                    ipoHistoryDataApi!.historyFound!.isEmpty) ||
                                (!(ipoHistoryDataApi!.historyFound == 'Y' ||
                                    ipoHistoryDataApi!.historyFound == 'N'))
                            ? CurrentlyUnavailableWidget(
                                refressFunc: () async {
                                  await fetchIPOHistoryDetailsInAPI(context);
                                },
                              )
                            : IpoHistoryPage(
                                ipoHistoryDetailsData: ipoHistoryDataApi!,
                                // ipoDisclaimer:
                                //     '${ipoMasterDataApi.disclaimer ?? ''}',
                              ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
            height: 60,
            backgroundColor: Colors.transparent,
            color: appPrimeColor,
            animationDuration: Duration(milliseconds: 500),
            index: _tabController.index,
            // index: changeindex.value - 1 < 0 ? 0 : changeindex.value - 1,
            onTap: (newValue) {
              _tabController.index = newValue;
              setState(() {});
              // ChangeNCBIndex().changeNCBIndex(0);
            },
            items: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Image.asset(
                  // 'assets/IPO Dark.png',
                  // 'assets/investIcon.jpg',
                  // 'assets/novoinvestIcon.png',
                  "assets/novoInvestIcon.png",
                  // "assets/money-sign (1).png",
                  width: 32,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/TransactionHistory.png',
                  width: 27,
                ),
              ),
              // Padding(
              //     padding: const EdgeInsets.all(4.0),
              //     child: Icon(
              //       Icons.transfer_within_a_station_outlined,
              //       color: Colors.white,
              //       size: 30,
              //     )),
            ]),
      ),
    );
  }
}
