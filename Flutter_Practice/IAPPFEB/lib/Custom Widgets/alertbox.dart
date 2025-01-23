import 'package:flutter/material.dart';

openAlertBox(
    {required BuildContext context,
    String? title,
    required String content,
    required onpressedButton1,
    onpressedButton2,
    String? button1Content,
    String? button2Content,
    Color? button1color,
    Color? button2color,
    bool needButton2 = true,
    barrierDismissible = true,
    canPop = true}) {
  showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      return PopScope(
        canPop: canPop,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10.0),
              ],
              Text(
                content,
                // "Are you want to go back ?",
                style: Theme.of(context).textTheme.displayMedium,
              )
            ],
          ),
          actions: [
            SizedBox(
              height: 30.0,
              child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(0),
                    backgroundColor: MaterialStatePropertyAll(
                        button1color ?? Theme.of(context).colorScheme.primary),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
                  ),
                  onPressed: onpressedButton1,
                  //  () {
                  //   Navigator.pop(context);
                  //   Navigator.pushNamedAndRemoveUntil(
                  //       context, route.nominee, (route) => false,
                  //       arguments: true);
                  // },
                  child: Text(button1Content ?? "Yes")),
            ),
            if (needButton2) ...[
              SizedBox(
                height: 30.0,
                child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor: MaterialStatePropertyAll(button2color ??
                          Theme.of(context).colorScheme.primary),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                    ),
                    onPressed: () {
                      onpressedButton2 != null
                          ? onpressedButton2()
                          : Navigator.pop(context);
                    },
                    child: Text(button2Content ?? "No")),
              )
            ]
          ],
        ),
      );
    },
  );
}



















// // File file = File('downloads/$fileName');  // file creation

// // // Convert Uint8List to Image
// //  Image image = img.decodeimage(Uint8list);

// //    await file.writeAsBytes(img.encodePng(image));

// //    //save video file
// //    await videoFile.copy(destinationFilepath);

// //    //directory exist or not

// //    Directory directory = Directory(directoryPath);
// //   bool b=await directory.exists();//future boolean value

// //   file.exist

// //   //directory creation

// //   Directory newDirectory = Directory('${appDocumentsDirectory.path}/$directoryName');
// //   await newDirectory.create(recursive: true);

// //   //
// //   Directory d = Directory('/downloads');
// //                                     String filename = 'save.img';
// //                                     if (await d.exists()) {
// //                                       for (var i = 0; i < 1000; i++) {
// //                                         File file =
// //                                             File('${d.path}/filename$i');
// //                                         if (await file.exists() == false) {
// //                                           file.writeAsBytes("Uint8list");
// //                                           break;
// //                                         }
// //                                       }
// //                                     }

// //                                     showDialog(
// //                                       context: context,
// //                                       builder: (context) => AlertDialog(
// //                                         // title: Text('Preview'),
// //                                         content: Container(
// //                                           decoration: BoxDecoration(
// //                                               borderRadius:
// //                                                   BorderRadius.circular(5)),
// //                                           height: MediaQuery.of(context)
// //                                                   .size
// //                                                   .height *
// //                                               0.75,
// //                                           width: MediaQuery.of(context)
// //                                                   .size
// //                                                   .width *
// //                                               0.85,
// //                                           child: Column(
// //                                             crossAxisAlignment:
// //                                                 CrossAxisAlignment.start,
// //                                             children: [
// //                                               Row(
// //                                                 mainAxisAlignment:
// //                                                     MainAxisAlignment
// //                                                         .spaceBetween,
// //                                                 children: [
// //                                                   IconButton(
// //                                                       onPressed: () {
// //                                                         Navigator.of(context)
// //                                                             .pop();
// //                                                       },
// //                                                       icon: Icon(
// //                                                         Icons.cancel,
// //                                                         color: Colors.blue,
// //                                                       )),
// //                                                   Text(
// //                                                     'Preview',
// //                                                     style: Theme.of(context)
// //                                                         .textTheme
// //                                                         .bodyLarge!
// //                                                         .copyWith(
// //                                                             color: Colors.blue),
// //                                                   ),
// //                                                   IconButton(
// //                                                       onPressed: () {
// //                                                         Navigator.of(context)
// //                                                             .pop();
// //                                                       },
// //                                                       icon: Icon(
// //                                                         Icons.download,
// //                                                         color: Colors.blue,
// //                                                       )),
// //                                                 ],
// //                                               ),
// //                                               Expanded(
// //                                                   child: Container(
// //                                                 child: Image.asset(
// //                                                   'assets/images/Rectangle.jpg',
// //                                                   fit: BoxFit.fill,
// //                                                 ),
// //                                               )),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     );

// import 'dart:io';
// import 'dart:typed_data';

// import '../Custom%20Widgets/custom_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:path_provider/path_provider.dart';

// import '../API call/api_call.dart';

// imageAlert(context, file) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       // title: Text('Preview'),
//       content: Container(
//         decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
//         height: MediaQuery.of(context).size.height * 0.75,
//         width: MediaQuery.of(context).size.width * 0.85,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     icon: Icon(
//                       Icons.close,
//                       color: Colors.blue,
//                     )),
//                 Text(
//                   'Preview',
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge!
//                       .copyWith(color: Colors.blue),
//                 ),
//                 IconButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     icon: Icon(
//                       Icons.download,
//                       color: Colors.blue,
//                     )),
//               ],
//             ),
//             Expanded(
//                 child:
//                     //      Container(
//                     //   child: Image.asset(
//                     //     'assets/images/Rectangle.jpg',
//                     //     fit: BoxFit.fill,
//                     //   ),
//                     // )
//                     Image.memory(
//               file,
//             )),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// pdfAlert(context, id, name, [ontap]) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       // title: Text('Preview'),
//       content: Container(
//         decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
//         height: MediaQuery.of(context).size.height * 0.75,
//         width: MediaQuery.of(context).size.width * 0.85,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     icon: Icon(
//                       Icons.close,
//                       color: Colors.blue,
//                     )),
//                 Text(
//                   'Preview',
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge!
//                       .copyWith(color: Colors.blue),
//                 ),
//                 IconButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     icon: Icon(
//                       Icons.download,
//                       color: Colors.blue,
//                     )),
//               ],
//             ),
//             Expanded(
//                 child: FutureBuilder<Uint8List>(
//               future: fetchFile(context: context, id: id),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Container(
//                       alignment: Alignment.center,
//                       child: const CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else if (!snapshot.hasData) {
//                   return Text('No image data');
//                 } else {
//                   print(snapshot.data);
//                   return PDFView(
//                     // filePath: snapshot.data!,
//                     pdfData: snapshot.data,
//                     enableSwipe: true,
//                     swipeHorizontal: false,
//                     autoSpacing: false,
//                     pageFling: false,
//                   );
//                 }
//               },
//             )),
//             Visibility(
//                 visible: ontap != null,
//                 child: Column(
//                   children: [
//                     const SizedBox(
//                       height: 20.0,
//                     ),
//                     CustomButton(onPressed: ontap),
//                   ],
//                 ))
//           ],
//         ),
//       ),
//     ),
//   );
// }
