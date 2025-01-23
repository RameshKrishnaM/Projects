import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

import '../../Firebase_setup/firebase_setup.dart';
import '../../widgets/MF Widgets/mfcustomListTile.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    getDetails();
    super.initState();
  }

  List messages = [];
  bool isLoaded = true;
  // final firebaseStorage = FirebaseFirestore.instance;
  getDetails() async {
    try {
      var details = await firestore
          .collection('global_Messages')
          .doc('Notifications')
          .get();
      if (details['message'] != null) {
        messages = details['message'];
        messages = messages.reversed.toList();

        isLoaded = false;
      } else {
        messages = [];
      }
    } catch (e) {
      // ////print(e);
      messages = [];
    }

    ////print('*****************');
    ////print(messages);
    // ////print(details.docs[0].data()['List']);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: themeBasedColor,
        title: Text('Notification'),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Row(
              //   children: [
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.pop(context);
              //       },
              //       child: Icon(
              //         Icons.arrow_back_ios_new,
              //         color: themeBasedColor,
              //         size: 20,
              //       ),
              //     ),
              //     const SizedBox(
              //       width: 10,
              //     ),
              //     Text(
              //       'Notifications',
              //       style: darkThemeMode
              //           ? ThemeClass.Darktheme.textTheme.titleMedium
              //           : ThemeClass.lighttheme.textTheme.titleMedium,
              //     ),
              //   ],
              // ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: isLoaded
                    ? const Center(
                        child: LoadingProgress(),
                      )
                    : messages.isNotEmpty
                        ? ListView.builder(
                            // separatorBuilder: (context, index) {
                            //   return Divider(
                            //     color: subTitleTextColor,
                            //     thickness: 2,
                            //   );
                            // },
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return

                                  // ListTile(
                                  //   minLeadingWidth: 0,

                                  //   leading: Container(
                                  //     // alignment: Alignment.topCenter,
                                  //     padding: EdgeInsets.all(12),
                                  //     decoration: BoxDecoration(
                                  //       color: modifyButtonColor,
                                  //       // color: Colors.red,
                                  //       borderRadius: BorderRadius.circular(50),
                                  //       // border: Border.all(
                                  //       //   width: 2,
                                  //       //   color:
                                  //       //       subTitleTextColor.withOpacity(0.2),

                                  //       //   // bottom:
                                  //       //   //     BorderSide(color: subTitleTextColor),
                                  //       // )
                                  //     ),
                                  //     child: const Icon(Icons.person),
                                  //   ),
                                  //   title: Container(
                                  //     padding: const EdgeInsets.only(left: 10),
                                  //     decoration: BoxDecoration(
                                  //         // color: Colors.red,
                                  //         border: Border(
                                  //       left: BorderSide(
                                  //         width: 2,
                                  //         color: subTitleTextColor.withOpacity(0.2),
                                  //       ),
                                  //       // bottom:
                                  //       //     BorderSide(color: subTitleTextColor),
                                  //     )),
                                  //     child: Column(
                                  //       mainAxisAlignment: MainAxisAlignment.center,
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.start,
                                  //       children: [
                                  //         Text(
                                  //           messages[index]['title'] ?? '',
                                  //           style: TextStyle(
                                  //               color: themeBasedColor,
                                  //               fontSize: 15),
                                  //         ),
                                  //         Row(
                                  //           mainAxisAlignment:
                                  //               MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Text(
                                  //               messages[index]['body'] ?? '',
                                  //               style: const TextStyle(
                                  //                 color: Colors.grey,
                                  //               ),
                                  //             ),
                                  //             Text(
                                  //               'Just now',
                                  //               style: TextStyle(
                                  //                   color: subTitleTextColor,
                                  //                   fontSize: 12),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //         const SizedBox(
                                  //           height: 5,
                                  //         )
                                  //       ],
                                  //     ),
                                  //   ),
                                  //   subtitle: Divider(
                                  //     color: subTitleTextColor,
                                  //     thickness: 0.3,
                                  //     indent: 10,
                                  //   ),
                                  //   // trailing: Text('Just now'),
                                  //   // onTap: () {
                                  //   //   ////print('Notificationm');
                                  //   //   ChangeIndex().value = 5;
                                  //   // },
                                  // );
                                  Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4),
                                child: MFCustomListTile(
                                  imageUrl: Container(
                                    // alignment: Alignment.topCenter,
                                    padding: EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 240, 239, 241),
                                      // color: Colors.red,
                                      borderRadius: BorderRadius.circular(50),
                                      // border: Border.all(
                                      //   width: 2,
                                      //   color:
                                      //       subTitleTextColor.withOpacity(0.2),

                                      //   // bottom:
                                      //   //     BorderSide(color: subTitleTextColor),
                                      // )
                                    ),
                                    // child: Icon(Icons.notifications)
                                    child: Image.asset(
                                      'assets/novo_logo_Transp.png',
                                      width: 23,
                                    ),
                                  ),
                                  title: messages[index]['title'] ?? '',
                                  subtitl1: Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Text(
                                        messages[index]['body'] ?? '',
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  subtitle2: Text(
                                    "${messages[index]['id'].toString().split(' ')[0]}\n${messages[index]['id'].toString().split(' ')[1].split('.')[0]}",
                                    style: TextStyle(
                                        color: subTitleTextColor, fontSize: 12),
                                  ),
                                ),
                              );

                              //     Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     crossAxisAlignment:
                              //         CrossAxisAlignment.center,
                              //     children: [
                              //       Row(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.start,
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.center,
                              //         children: [
                              //           Icon(
                              //             Icons.circle,
                              //             color: appPrimeColor,
                              //             size: 13,
                              //           ),
                              //           SizedBox(
                              //             width: 5,
                              //           ),
                              //           Container(
                              //             // alignment: Alignment.topCenter,
                              //             padding: EdgeInsets.all(13),
                              //             decoration: BoxDecoration(
                              //               color: Color.fromARGB(
                              //                   255, 240, 239, 241),
                              //               // color: Colors.red,
                              //               borderRadius:
                              //                   BorderRadius.circular(50),
                              //               // border: Border.all(
                              //               //   width: 2,
                              //               //   color:
                              //               //       subTitleTextColor.withOpacity(0.2),

                              //               //   // bottom:
                              //               //   //     BorderSide(color: subTitleTextColor),
                              //               // )
                              //             ),
                              //             // child: Icon(Icons.notifications)
                              //             child: Image.asset(
                              //               'assets/novo_logo_Transp.png',
                              //               width: 23,
                              //             ),
                              //           ),
                              //           Container(
                              //             width: MediaQuery.of(context)
                              //                     .size
                              //                     .width *
                              //                 0.55,
                              //             // alignment: Alignment.topCenter,
                              //             padding: EdgeInsets.only(left: 10),
                              //             margin: EdgeInsets.only(left: 10),
                              //             decoration: BoxDecoration(
                              //                 // color: modifyButtonColor,
                              //                 // color: Colors.red,
                              //                 // borderRadius: BorderRadius.circular(50),
                              //                 border: Border(
                              //               // width: 2,
                              //               // color:
                              //               //     subTitleTextColor.withOpacity(0.2),

                              //               left: BorderSide(
                              //                   color: subTitleTextColor,
                              //                   width: 0.3),
                              //               // bottom:
                              //               //     BorderSide(color: subTitleTextColor),
                              //             )),
                              //             child: Column(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.start,
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   messages[index]['title'] ??
                              //                       '',
                              //                   style: TextStyle(
                              //                       color: themeBasedColor,
                              //                       fontSize: 15),
                              //                 ),
                              //                 Text(
                              //                   messages[index]['body'] ?? '',
                              //                   softWrap: true,
                              //                   overflow:
                              //                       TextOverflow.visible,
                              //                   style: const TextStyle(
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 // Text(
                              //                 //   messages[index]['id'] ?? '',
                              //                 //   softWrap: true,
                              //                 //   overflow:
                              //                 //       TextOverflow.visible,
                              //                 //   style: const TextStyle(
                              //                 //     color: Colors.grey,
                              //                 //   ),
                              //                 // ),
                              //               ],
                              //             ),
                              //           ),
                              //           // SizedBox(
                              //           //   width: 10,
                              //           // ),
                              //           Expanded(
                              //             child: Text(
                              //               "${messages[index]['id'].toString().split(' ')[0]}\n${messages[index]['id'].toString().split(' ')[1].split('.')[0]}",
                              //               style: TextStyle(
                              //                   color: subTitleTextColor,
                              //                   fontSize: 12),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       Divider(
                              //         color: subTitleTextColor,
                              //         thickness: 0.3,
                              //         indent: 90,
                              //       ),
                              //     ],
                              //   ),
                              // );
                            },
                          )
                        : const Center(
                            child: Text('Nothing to see here , yet')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
