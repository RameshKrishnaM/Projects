import 'package:ekycold/esign.dart';
import 'package:ekycold/fileuploading.dart';
import 'package:ekycold/pageSwap.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PageSwap(),
        ),
        ChangeNotifierProvider(
          create: (context) => FileUploading(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ekycproject',
        home: Esign(),
      ),
    );
  }
}

// import 'package:ekycproject/lastStep.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return  const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'ekycproject',
       
//         home:LastStep(),
      
//     );
//   }
// }

// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         textTheme: TextTheme(
//           titleLarge: TextStyle(
//             color: Colors.yellow,
//           ),
//         ),
//         primarySwatch: Colors.green,
//       ),
//       home: MyHomePage(title: 'Screenshot Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   ScreenshotController screenshotController = ScreenshotController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Screenshot(
//               controller: screenshotController,
//               child: Container(
//                 padding: const EdgeInsets.all(30.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blueAccent, width: 5.0),
//                   color: Colors.amberAccent,
//                 ),
//                 child: Stack(
//                   children: [
//                     WebViewWidget(
//                       controller: WebViewController(),

//                       // initialUrl: 'https://www.example.com', // Replace with your URL
//                       // JavaScriptMode: JavaScriptMode.unrestricted,
//                     ),
//                     Text("This widget will be captured as an image"),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 // Capture screenshot
//                 Uint8List? capturedImage =
//                     await screenshotController.capture(delay: Duration(milliseconds: 10));
//                 if (capturedImage != null) {
//                   // Save the image to local storage
//                   _saveImage(capturedImage);
//                 }
//               },
//               child: Text('Capture and Save Screenshot'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _saveImage(Uint8List imageBytes) async {
//     final result = await ImageGallerySaver.saveImage(imageBytes);
//     if (result['isSuccess']) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Screenshot saved to gallery')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save screenshot')),
//       );
//     }
//   }
// }
