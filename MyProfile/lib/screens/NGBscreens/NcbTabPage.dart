import 'package:flutter/material.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/ncbModels/ncbHistoryModel.dart';
import 'package:novo/model/ncbModels/ncbmasterModel.dart';
import 'package:novo/screens/NGBscreens/NcbMainScreen.dart';
import 'package:novo/utils/colors.dart';

import 'package:provider/provider.dart';

import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';

class NcbTabPage extends StatefulWidget {
  NcbTabPage({super.key});

  @override
  State<NcbTabPage> createState() => _NcbTabPageState();
}

class _NcbTabPageState extends State<NcbTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _activeTabIndex = ChangeNCBIndex();
  // =_;
  @override
  void initState() {
    _tabController = TabController(
        length: 3, initialIndex: _activeTabIndex.value, vsync: this);

    fetchNcbDetailsInAPI(context);

    super.initState();
  }

  NcbMasterDetails? ncbMasterDataApi;
  String? ncbDesclaimer;
  String? investCount;
  //gsec Variables
  List<Detail>? gsecMasterDataList;
  String? gsecMasterFound;
  String? gsecNoDataText;
  //tBills Variables
  List<Detail>? tBillsMasterDataList;
  String? tBillsMasterFound;
  String? tBillsNoDataText;
  //Sdl Variables
  List<Detail>? sdlMasterDataList;
  String? sdlMasterFound;
  String? sdlNoDataText;

  //NCB historyDetails
  NcbHistoryModel? ncbHistoryDataApi;
  //gsec Variables
  List<OrderHistoryArr>? gsecHistoryDataList;
  String? gsecHistoryFound;
  String? gsecHistoryNoDataText;
  //tBills Variables
  List<OrderHistoryArr>? tBillsHistoryDataList;
  String? tBillsHistoryFound;
  String? tBillsHistoryNoDataText;
  //Sdl Variables
  List<OrderHistoryArr>? sdlHistoryDataList;
  String? sdlHistoryFound;
  String? sdlHistoryNoDataText;

  bool ncbPageLoading = true;

  fetchNcbDetailsInAPI(context) async {
    if (await isInternetConnected()) {
      ncbMasterDataApi = await fetchNcbDetails(context: context);
      ncbHistoryDataApi = await fetchNcbHistory(context: context);

      ncbDesclaimer = ncbMasterDataApi?.disclaimer;

      //gsec...
      gsecMasterDataList = ncbMasterDataApi?.gSecDetail;
      gsecMasterFound = ncbMasterDataApi?.goimasterFound;
      gsecNoDataText = ncbMasterDataApi?.goinoDataText;
      //tBills...
      tBillsMasterDataList = ncbMasterDataApi?.tBillDetail;
      tBillsMasterFound = ncbMasterDataApi?.tbillmasterFound;
      tBillsNoDataText = ncbMasterDataApi?.tbillnoDataText;

      //sdl....
      sdlMasterDataList = ncbMasterDataApi?.sdlDetail;
      sdlMasterFound = ncbMasterDataApi?.sdlmasterFound;
      sdlNoDataText = ncbMasterDataApi?.sdlnoDataText;

      //gsecHistory...
      gsecHistoryDataList = ncbHistoryDataApi?.gSecOrderHistoryArr;
      gsecHistoryFound = ncbHistoryDataApi?.goihistoryFound;
      gsecHistoryNoDataText = ncbHistoryDataApi?.goihistorynoDataText;
      //tBillsHistory...
      tBillsHistoryDataList = ncbHistoryDataApi?.tBillOrderHistoryArr;
      tBillsHistoryFound = ncbHistoryDataApi?.tbillhistoryFound;
      tBillsHistoryNoDataText = ncbHistoryDataApi?.tbillhistorynoDataText;

      //sdlHistory....
      sdlHistoryDataList = ncbHistoryDataApi?.sdlOrderHistoryArr;
      sdlHistoryFound = ncbHistoryDataApi?.sdlhistoryFound;
      sdlHistoryNoDataText = ncbHistoryDataApi?.sdlhistorynoDataText;
      if (mounted) {
        setState(() {
          ncbPageLoading = false;
        });
      }
    } else {
      noInternetConnectAlertDialog(
          context, () => fetchNcbDetailsInAPI(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    return ValueListenableBuilder(
        valueListenable: _activeTabIndex,
        builder: (contextcontext, value, child) {
          return DefaultTabController(
            // animationDuration: Durations.long1,
            // initialIndex: 0,

            length: 3,
            child: Scaffold(
              appBar: AppBar(
                // foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Provider.of<NavigationProvider>(context).themeMode ==
                              ThemeMode.dark
                          ? "assets/NCB W.png"
                          : "assets/NCB B.png",
                      width: 28.0,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'G-SEC',
                      style: TextStyle(
                          color: themeBasedColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kiro',
                          height: 0.5),
                    ),
                  ],
                ),

                bottom: TabBar(
                  controller: _tabController,
                  // onTap: (index) {
                  //   // _activeTabIndex.value = index;
                  //   // //////////print('_activeTabIndex.value');
                  //   // //////////print(_activeTabIndex.value);
                  // },
                  dividerColor: Colors.red,
                  indicatorColor: appPrimeColor,
                  dividerHeight: 100,
                  labelPadding: const EdgeInsets.all(0),
                  tabs: <Widget>[
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? "assets/GOI white.png"
                                : "assets/GOI_2.png",
                            width: 24.0,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text('Govt.Bonds',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeBasedColor)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? "assets/GSEC White.png"
                                : "assets/GSEC_1.png",
                            width: 24.0,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text('T-Bills',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeBasedColor)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? "assets/SDL White.png"
                                : "assets/SDL.png",
                            width: 24.0,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text('SDL',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeBasedColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  ncbPageLoading
                      ? const Center(
                          // child: CircularProgressIndicator(),
                          child: LoadingProgress(),
                        )
                      : ncbMasterDataApi == null || gsecMasterFound!.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    'Currently Unavailable,Try Again...'),
                                IconButton(
                                    iconSize: 30,
                                    splashColor: appPrimeColor,
                                    splashRadius: 20,
                                    onPressed: () async {
                                      await fetchNcbHistory(context: context);
                                    },
                                    icon: const Icon(Icons.refresh_outlined))
                              ],
                            )
                          : ncbHistoryDataApi == null ||
                                  gsecHistoryFound!.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                        'Currently Unavailable,Try Again...'),
                                    IconButton(
                                        iconSize: 30,
                                        splashColor: appPrimeColor,
                                        splashRadius: 20,
                                        onPressed: () async {
                                          await fetchNcbHistory(
                                              context: context);
                                        },
                                        icon:
                                            const Icon(Icons.refresh_outlined))
                                  ],
                                )
                              : NcbMainScreen(
                                  ncbMasterDetails: ncbMasterDataApi!,
                                  ncbMasterList: gsecMasterDataList!,
                                  ncbMasterFound: gsecMasterFound!,
                                  ncbNoDataText: gsecNoDataText!,
                                  ncbHistoryDetails: ncbHistoryDataApi!,
                                  ncbHistoryList: gsecHistoryDataList!,
                                  ncbHistoryFound: gsecHistoryFound!,
                                  ncbHistoryNoDataText: gsecHistoryNoDataText!,
                                  ncbDisclimer: ncbDesclaimer!,
                                  index: 0,
                                ),
                  ncbPageLoading
                      ? const Center(
                          // child: CircularProgressIndicator(),
                          child: LoadingProgress(),
                        )
                      : ncbMasterDataApi == null || tBillsMasterFound!.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    'Currently Unavailable,Try Again...'),
                                IconButton(
                                    iconSize: 30,
                                    splashColor: appPrimeColor,
                                    splashRadius: 20,
                                    onPressed: () async {
                                      await fetchNcbHistory(context: context);
                                    },
                                    icon: const Icon(Icons.refresh_outlined))
                              ],
                            )
                          : ncbHistoryDataApi == null ||
                                  tBillsHistoryFound!.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                        'Currently Unavailable,Try Again...'),
                                    IconButton(
                                        iconSize: 30,
                                        splashColor: appPrimeColor,
                                        splashRadius: 20,
                                        onPressed: () async {
                                          await fetchNcbHistory(
                                              context: context);
                                        },
                                        icon:
                                            const Icon(Icons.refresh_outlined))
                                  ],
                                )
                              : NcbMainScreen(
                                  ncbMasterDetails: ncbMasterDataApi!,
                                  ncbMasterList: tBillsMasterDataList!,
                                  ncbMasterFound: tBillsMasterFound!,
                                  ncbNoDataText: tBillsNoDataText!,
                                  ncbHistoryDetails: ncbHistoryDataApi!,
                                  ncbHistoryList: tBillsHistoryDataList!,
                                  ncbHistoryFound: tBillsHistoryFound!,
                                  ncbHistoryNoDataText:
                                      tBillsHistoryNoDataText!,
                                  ncbDisclimer: ncbDesclaimer!,
                                  index: 1,
                                ),
                  ncbPageLoading
                      ? const Center(
                          // child: CircularProgressIndicator(),
                          child: LoadingProgress(),
                        )
                      : ncbMasterDataApi == null || sdlMasterFound!.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    'Currently Unavailable,Try Again...'),
                                IconButton(
                                    iconSize: 30,
                                    splashColor: appPrimeColor,
                                    splashRadius: 20,
                                    onPressed: () async {
                                      await fetchNcbHistory(context: context);
                                    },
                                    icon: const Icon(Icons.refresh_outlined))
                              ],
                            )
                          : ncbHistoryDataApi == null ||
                                  sdlHistoryFound!.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                        'Currently Unavailable,Try Again...'),
                                    IconButton(
                                        iconSize: 30,
                                        splashColor: appPrimeColor,
                                        splashRadius: 20,
                                        onPressed: () async {
                                          await fetchNcbHistory(
                                              context: context);
                                        },
                                        icon:
                                            const Icon(Icons.refresh_outlined))
                                  ],
                                )
                              : NcbMainScreen(
                                  ncbMasterDetails: ncbMasterDataApi!,
                                  ncbMasterList: sdlMasterDataList!,
                                  ncbMasterFound: sdlMasterFound!,
                                  ncbNoDataText: sdlNoDataText!,
                                  ncbHistoryDetails: ncbHistoryDataApi!,
                                  ncbHistoryList: sdlHistoryDataList!,
                                  ncbHistoryFound: sdlHistoryFound!,
                                  ncbHistoryNoDataText: sdlHistoryNoDataText!,
                                  ncbDisclimer: ncbDesclaimer!,
                                  index: 2,
                                ),
                ],
              ),
            ),
          );
        });
  }
}
