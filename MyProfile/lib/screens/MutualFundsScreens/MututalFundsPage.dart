// ignore_for_file: file_names

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/mfModels/mfschemeMasterDetails.dart';
import 'package:novo/screens/MutualFundsScreens/MfCardScreen.dart';
import 'package:novo/screens/MutualFundsScreens/MfDashBoard.dart';
import 'package:novo/screens/MutualFundsScreens/MfHistoryScreen.dart';
import 'package:novo/screens/MutualFundsScreens/MfPortfolioScreen.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/MF%20Widgets/Mf_Button_Widget.dart';
import 'package:novo/widgets/MF%20Widgets/checkbox_container.dart';
import 'package:novo/widgets/MF%20Widgets/mf_Dashboard_Widgets/filtercountcontainer.dart';
import 'package:novo/widgets/NOVO%20Widgets/customLoadingAni.dart';
import 'package:novo/widgets/NOVO%20Widgets/loadingDailogwithCircle.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../API/MFAPICall.dart';
import '../../widgets/MF Widgets/MfRiskDiscloser.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';

class MfMainScreen extends StatefulWidget {
  const MfMainScreen({super.key});

  @override
  State<MfMainScreen> createState() => _MfMainScreenState();
}

class _MfMainScreenState extends State<MfMainScreen>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  bool showFilter = false;
  bool isChecked = false;
  bool showbottom = false;
  List<Widget> pageList = [];
  MfSchemeMasterDetails? mfSchemeMasterDetails;
  // final FocusNode _focusNode = FocusNode();

  // List<MfSchemeMasterArr>? mfSchemeMasterArr;
  // List<MfSchemeMasterArr>? mfSchemeMasterFilterArr;
  Map<String, dynamic>? mfSchemeTypeDetails;
  List<dynamic> mfFilterTypeArr = [];
  List mffilterCategoryArr = [];
  List<String> singleFilterArr = [];
  String schemeDisclaimer = '';
  String _selectedOption = 'A-Z';
  String filterKey = '';
  // String showRisk = 'N';
  // String riskDiscription = '';
  final mfChangeIndex = MFChangeIndex();
  TextEditingController mfSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _filterScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    intialFunction(context);
    // mfSearchController.addListener(() {
    //   print('listen');
    //   searchdata(context, mfSearchController.text);
    // });
    // _focusNode.requestFocus();

    // _focusNode.addListener(() {
    //   print(_focusNode.hasFocus);
    //   print(!_focusNode.hasFocus);
    //   if (!_focusNode.hasFocus) {
    //     // searchdata(context, searchvalue);
    //     print('***********');
    //     // _focusNode.requestFocus();
    //   }
    // });
  }

/* 
Method Name: intialFunction
Purpose : This method used to Initialize the Needed API Calls and Initilize needed Methods For SchemeMaster,Scheme type.
InternetCheck:Yes
Parameter :context
Response :

On Success:
===========
In case of a successful execution of this method, get the SchemeMasterDetails,SchemeTypeDetails

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error.

Author : SRI PARAMASIVAM
Date : 23-July-2024

*/
  intialFunction(context) async {
    if (await isInternetConnected()) {
      mfChangeIndex.value = 0;
      // Provider.of<NavigationProvider>(context, listen: false)
      //     .getMfCheckActivateAPI(context);
      getMfSchemeMasterDetailsAPI(
          context); //Fetch The MFSchemeMasterDetails From API with Provider(Show The MFschemeMaster Details in Explore Page)
      getMfSchemeTypeAPI(
          context); //Fetch The MfSchemeTypeAPI From the API (Show The Filter Details)
      Provider.of<NavigationProvider>(context, listen: false).getmfCartcountAPI(
          context); //Get the CartCount From The API with Provider Value.
      showRiskDiscloser(context);
      mfSearchController.addListener(() {
        searchdata(context, mfSearchController.text);
      });
    } else {
      noInternetConnectAlertDialog(context, () => intialFunction(context));
    }
  }

//Get The MFSchemeMasterAPI(+)

  getMfSchemeMasterDetailsAPI(context) async {
    await Provider.of<NavigationProvider>(context, listen: false)
        .getmfmasterschemeApi(context);
    mfSchemeMasterDetails =
        Provider.of<NavigationProvider>(context, listen: false)
            .mfSchemeMasterDetails;

    schemeDisclaimer = mfSchemeMasterDetails!.mfDisclosureMessage ?? '';
    // var response = await fetchMfDisclimarPop(context);
    // showRisk = response['disclaimerstatus'];

    // if (showRisk == 'N') {
    //   riskDiscription = response['disclaimermsg'];
    //   showmfRiskDialog(
    //       context: context,
    //       title: 'Risk Disclosure',
    //       discription: riskDiscription,
    //       func: () async {
    //         Map<String, dynamic> reqData = {"disclaimerflag": "Y"};
    //         var response = await fetchMfDisclimarFlag(context, reqData);
    //         if (response['status'] == 'S') {
    //           Navigator.pop(context);
    //         }
    //       });
    // }
    Provider.of<NavigationProvider>(context, listen: false)
        .changePledgeableInfo(mfSchemeMasterDetails!.pledgeableInfo ?? "");

    pageList = [
      MFdashBoardScreen(
        scrollController: _scrollController,
        schemeDisclaimer: schemeDisclaimer,
        mfNFOM1: mfSchemeMasterDetails?.mfNFOM1 ?? '',
        mfNFOM2: mfSchemeMasterDetails?.mfNFOM2 ?? '',
      ),
      const MFportfolioScreen(),
      const MFhistoryScreen(),
      const MFcardScreen(),
    ];
    setState(() {
      isLoading = false;
    });
  }

  // showRiskDiscloser() async {
  //   var response = await fetchMfDisclimarPop(context);
  //   showRisk = response['disclaimerstatus'];

  //   if (showRisk == 'N') {
  //     riskDiscription = response['disclaimermsg'];
  //     showmfRiskDialog(
  //         context: context,
  //         title: 'Risk Disclosure',
  //         discription: riskDiscription,
  //         func: () async {
  //           Map<String, dynamic> reqData = {"disclaimerflag": "Y"};
  //           var response = await fetchMfDisclimarFlag(context, reqData);
  //           if (response['status'] == 'S') {
  //             Navigator.pop(context);
  //           }
  //         });
  //   }
  // }

  String showRisk = 'N';
  String riskDiscription = '';
  showRiskDiscloser(context) async {
    var response = await fetchMfDisclimarPop(context);
    showRisk = response['disclaimerstatus'];

    if (showRisk == 'N') {
      riskDiscription = response['disclaimermsg'];
      showmfRiskDialog(
          context: context,
          title: 'Risk Disclosure',
          discription: riskDiscription,
          func: () async {
            Map<String, dynamic> reqData = {"disclaimerflag": "Y"};
            var response = await fetchMfDisclimarFlag(context, reqData);
            if (response['status'] == 'S') {
              Navigator.pop(context);
            }
          });
    }
  }

//Get The MFSchemeMasterAPI(-)
  bool filterLoaded = true;
//Get The MFSchemeTypeAPI(+)
  getMfSchemeTypeAPI(context) async {
    NavigationProvider mfSchemeProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    mfSchemeProvider.amcFilterArr = [];
    mfSchemeProvider.categoryFilterArr = [];
    mfSchemeProvider.pledgableFilterKey = "";
    mfSchemeProvider.sortOrder = "NAMEASC";

    mfSchemeTypeDetails = await fetchMfSchemeTypeDetails(
        context: context,
        amcFilterArr: [],
        categoryFilterArr: [],
        pledgableFilterKey: '',
        sortOrder: '');
    mfFilterTypeArr = mfSchemeTypeDetails!['mfFilterTypeArr'];
    if (mfSchemeTypeDetails != null) {
      filterKey = mfFilterTypeArr[0];
      for (var element in mfFilterTypeArr) {
        if (mfSchemeTypeDetails![element] is List) {
          for (var element1 in mfSchemeTypeDetails![element]!) {
            element1["isChecked"] = false;
          }
        }
      }

      mffilterCategoryArr = mfSchemeTypeDetails!['Category'];
      filterLoaded = false;
    }
    setState(() {});
  }
  //Get The MFSchemeTypeAPI(-)

//Sort Function(+)
  sortFuction(context) async {
    mfChangeIndex.value = 0;
    loadingDailogWithCircle(context);

    NavigationProvider mfSchemeProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    switch (_selectedOption) {
      case 'A-Z':
        mfSchemeProvider.sortOrder = 'NAMEASC';
        break;
      case 'Z-A':
        mfSchemeProvider.sortOrder = 'NAMEDESC';
        break;
      case 'NAV Low to High':
        mfSchemeProvider.sortOrder = 'NAVASC';
        break;
      case 'NAV High to Low':
        mfSchemeProvider.sortOrder = 'NAVDESC';
        break;
      default:
        mfSchemeProvider.sortOrder = 'NAMEASC';
        break;
    }
    await mfSchemeProvider.getmfmasterschemeApi(context);
    Navigator.pop(context);
    searchdata(context, mfSearchController.text);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

//Sort Function(-)

//Filter are Two Ways to filter the scheme singleFilter,MultipleFilter...

//SingleFilter(++)

//This Method is Used to single schemetype filter for CategoryArr...

//mfSingleFilterMethod(+)
  void mfSingleFilterMethod(int index) async {
    try {
      // for (var element in mffilterCategoryArr) {
      //   element['isChecked'] = false;
      // }
      mffilterCategoryArr[index]['isChecked'] =
          !(mffilterCategoryArr[index]['isChecked'] ?? false);

      if (mffilterCategoryArr[index]['isChecked']) {
        Provider.of<NavigationProvider>(context, listen: false)
            .categoryFilterArr
            .add(mffilterCategoryArr[index]['schemeType']);
      } else {
        Provider.of<NavigationProvider>(context, listen: false)
            .categoryFilterArr
            .remove(mffilterCategoryArr[index]['schemeType']);
      }

      applyFilterApi(context);
      setState(() {});
    } catch (e) {
      print('mfsinglefiltermethod catch');
      print(e);
    }
  }
  //mfSingleFilterMethod(-)

//This was Click the Particular SchemeType call the MfschemeMaster API and Implement the filter Function...
//applySingleFilterApi(+)
  // applySingleFilterApi(List singleAmcArr, context) async {
  //   try {
  //     NavigationProvider mfSchemeProvider =
  //         Provider.of<NavigationProvider>(context, listen: false);
  //     loadingDailogWithCircle(context);
  //     // mfSchemeMasterFilterArr =
  //     await mfSchemeProvider.getmfmasterschemeApi(context);
  //     setState(() {
  //       List<Map<String, dynamic>> dataList =
  //           List<Map<String, dynamic>>.from(mfSchemeTypeDetails![filterKey]);
  //       print("dataList");
  //       print(dataList);
  //       dataList.sort((a, b) => (b["isChecked"] ?? false)
  //           .toString()
  //           .compareTo((a["isChecked"] ?? false).toString()));
  //       mfSchemeTypeDetails![filterKey] = dataList;
  //     });
  //     showFilter = false;
  //     Navigator.pop(context);
  //     mfChangeIndex.value = 0;

  //     if (_scrollController.hasClients) {
  //       _scrollController.animateTo(
  //         0.0,
  //         duration: const Duration(milliseconds: 300),
  //         curve: Curves.easeOut,
  //       );
  //     }

  //     setState(() {});
  //   } catch (e) {
  //     print('singlefilter catch');
  //     print(e);
  //   }
  // }
  //applySingleFilterApi(+)

//SingleFilter(--)

//MultipleFilter(++)
//MFmultipleFilterMethod(+)
  void mfMultipleFilterMethod(
      List<Map<String, dynamic>> dataList, Map<String, dynamic> data) {
    NavigationProvider mfSchemeProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    setState(() {
      if (filterKey == 'Others') {
        for (var item in dataList) {
          if (item != data) {
            item['isChecked'] = false;
          }
        }
        // Toggle the selected item
        data['isChecked'] = !(data['isChecked'] ?? false);

        // Perform additional actions based on the new state of data['isChecked']
        if (data['isChecked']) {
          mfSchemeProvider.pledgableFilterKey = data['pledgeFilterKey'];
        } else {
          mfSchemeProvider.pledgableFilterKey = '';
        }
      } else {
        data['isChecked'] = !(data['isChecked'] ?? false);

        if (data['isChecked']) {
          if (filterKey == mfFilterTypeArr[0]) {
            mfSchemeProvider.amcFilterArr.add(data['schemeCode']);
          } else if (filterKey == mfFilterTypeArr[1]) {
            mfSchemeProvider.categoryFilterArr.add(data['schemeType']);
          }
        } else {
          if (filterKey == mfFilterTypeArr[0]) {
            mfSchemeProvider.amcFilterArr.remove(data['schemeCode']);
          } else if (filterKey == mfFilterTypeArr[1]) {
            mfSchemeProvider.categoryFilterArr.remove(data['schemeType']);
          }
        }
      }
    });
  }

  //MFmultipleFilterMethod(+)
//The User Click the Apply Button Call the MfSchemeMasterAPI
  applyFilterApi(context) async {
    try {
      showFilter = false;
      NavigationProvider mfSchemeProvider =
          Provider.of<NavigationProvider>(context, listen: false);
      loadingDailogWithCircle(context);
      await mfSchemeProvider.getmfmasterschemeApi(context);
      Navigator.pop(context);
      mfChangeIndex.value = 0;
      setState(() {
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(mfSchemeTypeDetails![filterKey]);
        dataList.sort((a, b) => (b["isChecked"] ?? false)
            .toString()
            .compareTo((a["isChecked"] ?? false).toString()));
        mfSchemeTypeDetails![filterKey] = dataList;
      });
      searchdata(context, mfSearchController.text);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print('applyfiltercatch');
      print(e);
    }
  }

  clearFilterApi(context) async {
    try {
      showFilter = false;
      NavigationProvider mfSchemeProvider =
          Provider.of<NavigationProvider>(context, listen: false);
      setState(() {});
      loadingDailogWithCircle(context);
      for (var element in mfFilterTypeArr) {
        if (mfSchemeTypeDetails![element] is List) {
          for (var element1 in mfSchemeTypeDetails![element]!) {
            element1["isChecked"] = false;
          }
        }
      }
      mfSchemeProvider.amcFilterArr.clear();
      mfSchemeProvider.categoryFilterArr.clear();
      mfSchemeProvider.pledgableFilterKey = '';
      singleFilterArr.clear();
      mfSearchController.clear();
      // mfSchemeMasterFilterArr =
      await mfSchemeProvider.getmfmasterschemeApi(context);

      Navigator.pop(context);
      mfChangeIndex.value = 0;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      setState(() {});
    } catch (e) {
      print('clear filter catch');
      print(e);
    }
  }

  // String searchvalue = '';
  void searchdata(context, String value) async {
    NavigationProvider mfSchemeProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    if (value.isEmpty) {
      await mfSchemeProvider.getmfmasterschemeApi(context);
      // await mfSchemeProvider.getmfmasterschemeTypeApi(context);
      // mfSchemeMasterFilterArr = mfSchemeProvider
      //     .changeMfSchemeMasterFilterArr(mfSchemeMasterFilterArr!);
    } else {
      var filteredList = mfSchemeProvider
          .mfSchemeMasterDetails!.mfSchemeMasterArr!
          .where((data) {
        return data.schemeName
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            data.isin.toString().toLowerCase().contains(value.toLowerCase());
      }).toList();

      mfSchemeProvider.changeMfSchemeMasterFilterArr(filteredList);
    }
  }

  void clearSearch() {
    mfSearchController.clear();
    searchdata(context, ''); // Clear search results
  }

  @override
  void dispose() {
    _scrollController.dispose();

    if (mfChangeIndex.value != 0) {
      mfSearchController.dispose();
      Provider.of<NavigationProvider>(context, listen: false)
          .focusNode
          .dispose();
      // _focusNode.dispose();
    }

    super.dispose();
  }

  // Widget mfActiveStatus() {
  //   print('+++++++++++');
  //   // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   //   showRiskDisclosureDialog(context);
  //   // });
  //   return Container(
  //     color: Colors.transparent,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    NavigationProvider mfSchemeProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    return isLoading
        ? const Center(
            child: LoadingProgress(),
          )
        : ValueListenableBuilder<int>(
            valueListenable: mfChangeIndex,
            builder: (context, value, child) {
              return GestureDetector(
                onTap: () {
                  // FocusScope.of(context).unfocus();
                  if (mfSchemeProvider.focusNode.hasFocus) {
                    mfSchemeProvider.focusNode.unfocus();
                  }
                },
                child: Scaffold(
                  appBar: AppBar(
                    bottom: showbottom || showFilter || mfChangeIndex.value != 0
                        ? const PreferredSize(
                            preferredSize: Size.zero, child: SizedBox())
                        : PreferredSize(
                            preferredSize: const Size.fromHeight(60),
                            child: Container(
                              height: 60,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Skeletonizer(
                                enabled: filterLoaded,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: mffilterCategoryArr.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () => mfSingleFilterMethod(index),
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: darkThemeMode
                                                      ? const Color.fromARGB(
                                                              255,
                                                              230,
                                                              228,
                                                              228)
                                                          .withOpacity(0.1)
                                                      : Colors.grey.shade200
                                                          .withOpacity(0.9),
                                                  offset: const Offset(
                                                    2.0,
                                                    2.0,
                                                  ),
                                                  blurRadius: 3.0,
                                                  spreadRadius: 6.0,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color: darkThemeMode
                                                      ? mffilterCategoryArr[
                                                                      index][
                                                                  'isChecked'] ==
                                                              true
                                                          ? appPrimeColor
                                                          : const Color
                                                              .fromRGBO(
                                                              48, 48, 48, 1)
                                                      : mffilterCategoryArr[
                                                                      index][
                                                                  'isChecked'] ==
                                                              true
                                                          ? appPrimeColor
                                                          : Colors.white,
                                                  offset: const Offset(
                                                    0.0,
                                                    0.0,
                                                  ),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 5.0,
                                                ), //BoxShadow
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                    mffilterCategoryArr[index]
                                                            ['schemeName']
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color: mffilterCategoryArr[
                                                                            index]
                                                                        [
                                                                        'isChecked'] ==
                                                                    true
                                                                ? titleTextColorDark
                                                                : null,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                Container(
                                                  padding: mffilterCategoryArr[
                                                                  index]
                                                              ['schemeName'] ==
                                                          'NFO'
                                                      ? const EdgeInsets.only(
                                                          left: 4,
                                                          right: 4,
                                                          bottom: 1,
                                                          top: 0)
                                                      : EdgeInsets.zero,
                                                  decoration: mffilterCategoryArr[
                                                                  index]
                                                              ['schemeName'] ==
                                                          'NFO'
                                                      ? BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          color:
                                                              primaryGreenColor)
                                                      : null,
                                                  child: Text(
                                                      mffilterCategoryArr[index]['schemeCount'] >= 100
                                                          ? '${mffilterCategoryArr[index]['schemeCount'].toString()}+'
                                                          : mffilterCategoryArr[index]['schemeCount']
                                                              .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .copyWith(
                                                              fontSize:
                                                                  mffilterCategoryArr[index]['schemeName'] == 'NFO'
                                                                      ? 11
                                                                      : 12,
                                                              color: mffilterCategoryArr[index]['isChecked'] ==
                                                                          true ||
                                                                      mffilterCategoryArr[index]['schemeName'] ==
                                                                          'NFO'
                                                                  ? titleTextColorDark
                                                                  : null,
                                                              fontWeight:
                                                                  FontWeight.bold)),
                                                )
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: mffilterCategoryArr[index]
                                                    ['schemeName'] ==
                                                'NFO',
                                            child: Positioned(
                                                left: 44,
                                                top: 10,
                                                child: Image.asset(
                                                  'assets/stattransp.gif',
                                                  width: 13,
                                                  height: 13,
                                                )),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: MediaQuery.of(context).size.height * 0.13,
                    title: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              darkThemeMode
                                  ? "assets/MF WNovo Icon.png"
                                  : "assets/MF BNovo Icon.png",
                              width: 25.0,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text('Mutual Funds',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22)),
                          ],
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: SizedBox(
                              height: 35,
                              child: TextFormField(
                                focusNode: mfSchemeProvider.focusNode,
                                controller: mfSearchController,
                                // cursorHeight: 14,
                                textAlign: TextAlign.start,
                                onChanged: (value) {
                                  mfChangeIndex.value = 0;

                                  searchdata(
                                    context,
                                    value,
                                  );
                                  // setState(() {});
                                },

                                // autofocus: true,
                                // onTapAlwaysCalled: true,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    isDense: true,

                                    // contentPadding: EdgeInsets.
                                    // isCollapsed: true,
                                    hintText: "Explore more funds",
                                    suffixIcon: mfSearchController.text.isEmpty
                                        ? Icon(
                                            Icons.search,
                                            color: darkThemeMode
                                                ? titleTextColorDark
                                                : titleTextColorLight,
                                            size: 23,
                                          )
                                        : InkWell(
                                            onTap: clearSearch,
                                            child: Icon(
                                              Icons.clear,
                                              color: darkThemeMode
                                                  ? titleTextColorDark
                                                  : titleTextColorLight,
                                              size: 23,
                                            ),
                                          ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                            color: Color.fromRGBO(
                                                226, 226, 226, 1))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                            color: Color.fromRGBO(
                                                226, 226, 226, 1)))),
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                top: 5,
                              ),
                              child: PopupMenuButton<String>(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? titleTextColorLight
                                    : titleTextColorDark,
                                offset: const Offset(0, 30),
                                onOpened: () {
                                  showFilter = false;
                                  setState(() {});
                                },
                                onSelected: (String result) {
                                  setState(() {
                                    _selectedOption = result;
                                  });
                                  sortFuction(context);
                                },
                                child: Icon(
                                  CupertinoIcons.line_horizontal_3_decrease,
                                  color: darkThemeMode
                                      ? titleTextColorDark
                                      : titleTextColorLight,
                                  size: 23,
                                ),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  ...sortList.map(
                                    (e) => PopupMenuItem<String>(
                                      value: e,
                                      height: 30,
                                      child: Row(
                                        children: [
                                          _selectedOption != e
                                              ? Icon(
                                                  Icons.circle_outlined,
                                                  color: darkThemeMode
                                                      ? titleTextColorDark
                                                      : titleTextColorLight,
                                                  size: 15,
                                                )
                                              : Icon(
                                                  Icons.circle,
                                                  size: 15,
                                                  color: darkThemeMode
                                                      ? Colors.blue
                                                      : appPrimeColor,
                                                ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(e,
                                              style: _selectedOption == e
                                                  ? TextStyle(
                                                      color: darkThemeMode
                                                          ? Colors.blue
                                                          : appPrimeColor,
                                                      fontSize: 13)
                                                  : TextStyle(
                                                      color: darkThemeMode
                                                          ? titleTextColorDark
                                                          : titleTextColorLight,
                                                      fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Stack(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(top: 5, right: 3),
                                  child: InkWell(
                                    onTap: () async {
                                      showFilter = !showFilter;
                                      if (!showFilter) {
                                        await applyFilterApi(context);
                                      }

                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.filter_alt_rounded,
                                      color: darkThemeMode
                                          ? (mfSchemeProvider
                                                      .categoryFilterArr.isNotEmpty ||
                                                  mfSchemeProvider.amcFilterArr
                                                      .isNotEmpty ||
                                                  mfSchemeProvider
                                                      .pledgableFilterKey
                                                      .isNotEmpty)
                                              ? primaryGreenColor
                                              : titleTextColorDark
                                          : (mfSchemeProvider.categoryFilterArr
                                                      .isNotEmpty ||
                                                  mfSchemeProvider.amcFilterArr
                                                      .isNotEmpty ||
                                                  mfSchemeProvider
                                                      .pledgableFilterKey
                                                      .isNotEmpty)
                                              ? primaryGreenColor
                                              : titleTextColorLight,
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: (mfSchemeProvider
                                            .categoryFilterArr.isNotEmpty ||
                                        mfSchemeProvider
                                            .amcFilterArr.isNotEmpty ||
                                        mfSchemeProvider
                                            .pledgableFilterKey.isNotEmpty),
                                    child: Positioned(
                                        right: 0,
                                        top: 1,
                                        child: Container(
                                          height: 13,
                                          width: 13,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: primaryGreenColor),
                                          child: Center(
                                            child: Text(
                                              '${mfSchemeProvider.categoryFilterArr.length + mfSchemeProvider.amcFilterArr.length + mfSchemeProvider.pledgableFilterKey.length}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 7,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )))
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  body: Stack(
                    children: [
                      pageList[mfChangeIndex.getIndex],
                      Container(
                        height:
                            showFilter ? MediaQuery.of(context).size.height : 0,
                        color: Colors.black.withOpacity(0.3),
                        alignment: Alignment.topCenter,
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: showFilter
                              ? AnimatedContainer(
                                  duration: const Duration(milliseconds: 0),
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.35,
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      mfFilterTypeArr.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          filterKey =
                                                              mfFilterTypeArr[
                                                                  index];
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: filterKey ==
                                                                        mfFilterTypeArr[
                                                                            index]
                                                                    ? darkThemeMode
                                                                        ? modifyButtonColor.withOpacity(
                                                                            0.3)
                                                                        : modifyButtonColor.withOpacity(
                                                                            0.5)
                                                                    : Colors
                                                                        .transparent,
                                                                border: BorderDirectional(
                                                                    bottom: BorderSide(
                                                                        color: subTitleTextColor
                                                                            .withOpacity(0.2)))),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              mfFilterTypeArr[
                                                                      index]
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                      color: filterKey ==
                                                                              mfFilterTypeArr[
                                                                                  index]
                                                                          ? darkThemeMode
                                                                              ? Colors
                                                                                  .blue.shade500
                                                                              : appPrimeColor
                                                                          : darkThemeMode
                                                                              ? titleTextColorDark
                                                                              : titleTextColorLight,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            mfFilterTypeArr[
                                                                        index] ==
                                                                    'AMC'
                                                                ? CustomMfFilterCountContianer(
                                                                    filtercount:
                                                                        '${mfSchemeProvider.amcFilterArr.length}',
                                                                    isVisible: mfSchemeProvider
                                                                        .amcFilterArr
                                                                        .isNotEmpty,
                                                                  )
                                                                : mfFilterTypeArr[
                                                                            index] ==
                                                                        'Category'
                                                                    ? CustomMfFilterCountContianer(
                                                                        filtercount:
                                                                            '${mfSchemeProvider.categoryFilterArr.length}',
                                                                        isVisible: mfSchemeProvider
                                                                            .categoryFilterArr
                                                                            .isNotEmpty,
                                                                      )
                                                                    : mfFilterTypeArr[index] ==
                                                                            'Others'
                                                                        ? CustomMfFilterCountContianer(
                                                                            filtercount:
                                                                                '${mfSchemeProvider.pledgableFilterKey.length}',
                                                                            isVisible:
                                                                                // false,
                                                                                mfSchemeProvider.pledgableFilterKey.isNotEmpty)
                                                                        : const CustomMfFilterCountContianer(
                                                                            filtercount:
                                                                                '',
                                                                            isVisible:
                                                                                false,
                                                                          )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )),
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              decoration: BoxDecoration(
                                                  border: BorderDirectional(
                                                      start: BorderSide(
                                                          color:
                                                              subTitleTextColor
                                                                  .withOpacity(
                                                                      0.2)))),
                                              child: Scrollbar(
                                                thumbVisibility: true,
                                                controller:
                                                    _filterScrollController,
                                                child: ListView.builder(
                                                  controller:
                                                      _filterScrollController,
                                                  itemCount: filterKey.isEmpty
                                                      ? 0
                                                      : (mfSchemeTypeDetails![
                                                                  filterKey]
                                                              as List)
                                                          .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    List<Map<String, dynamic>>
                                                        dataList = List<
                                                                Map<String,
                                                                    dynamic>>.from(
                                                            mfSchemeTypeDetails![
                                                                filterKey]);
                                                    Map<String, dynamic> data =
                                                        filterKey.isEmpty
                                                            ? {}
                                                            : dataList[index];

                                                    return InkWell(
                                                      onTap: () {
                                                        mfMultipleFilterMethod(
                                                            dataList, data);
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left: 10,
                                                            top: 5,
                                                            right: 10,
                                                            bottom: 5
                                                            // horizontal: 0,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            CustomCheckBoxContainer(
                                                              isChecked: data[
                                                                      "isChecked"] ??
                                                                  false,
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                                child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.52,
                                                              child: Wrap(
                                                                direction: Axis
                                                                    .horizontal,
                                                                crossAxisAlignment:
                                                                    WrapCrossAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    filterKey ==
                                                                            'Others'
                                                                        ? data["pledgeFilterName"]
                                                                            .toString()
                                                                        : data["schemeName"]
                                                                            .toString(),
                                                                    softWrap:
                                                                        true,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                            fontSize:
                                                                                13),
                                                                  ),
                                                                  filterKey ==
                                                                          'Others'
                                                                      ? Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 2),
                                                                          child:
                                                                              Image.asset(
                                                                            'assets/pledgedicon.png',
                                                                            height:
                                                                                13,
                                                                            width:
                                                                                13,
                                                                          ),
                                                                        )
                                                                      : const SizedBox(),
                                                                ],
                                                              ),
                                                            )),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            child: CustomButton(
                                                isSmall: true,
                                                buttonWidget: const Text(
                                                  'Apply',
                                                  style: TextStyle(
                                                      fontFamily: 'inter',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white),
                                                ),
                                                onTapFunc: () async {
                                                  await applyFilterApi(context);
                                                }),
                                          ),
                                          const SizedBox(
                                            width: 40,
                                          ),
                                          SizedBox(
                                            // height: 30,
                                            child: CustomButton(
                                                backgroundColor:
                                                    primaryRedColor,
                                                isSmall: true,
                                                buttonWidget: const Text(
                                                  'Clear Filter',
                                                  style: TextStyle(
                                                      fontFamily: 'inter',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white),
                                                ),
                                                onTapFunc: () async {
                                                  await clearFilterApi(context);
                                                }),
                                          ),
                                          const SizedBox(
                                            width: 40,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ))
                              : const SizedBox(),
                        ),
                      )
                    ],
                  ),
                  bottomNavigationBar: showFilter
                      ? const SizedBox()
                      : CurvedNavigationBar(
                          height: 60,
                          backgroundColor: Colors.transparent,
                          color: appPrimeColor,
                          animationDuration: const Duration(milliseconds: 500),
                          index: mfChangeIndex.getIndex,
                          onTap: (newValue) {
                            mfChangeIndex.value = newValue;
                            if (mfChangeIndex.value != 0) {
                              mfSearchController.clear();
                            }
                          },
                          items: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/Explore.png',
                                  width: 25,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/Dashboard.png',
                                  width: 25,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/TransactionHistory.png',
                                  width: 25,
                                ),
                              ),
                              Stack(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Image.asset(
                                        'assets/Cart.png',
                                        color: Colors.white,
                                        width: 25,
                                      )),
                                  mfSchemeProvider.mfcartcount == 0
                                      ? const SizedBox()
                                      : Positioned(
                                          bottom: 18,
                                          left: 18,
                                          child: Container(
                                            height: 15,
                                            width: 15,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: primaryGreenColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                              mfSchemeProvider.mfcartcount
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: titleTextColorDark,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ]),
                ),
              );
            });
  }

  @override
  bool get wantKeepAlive => true;
}
