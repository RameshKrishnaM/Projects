import 'package:flutter/material.dart';
import 'package:project2/screen1.dart';
import 'package:project2/esign.dart';
import 'package:project2/fileuploading.dart';
import 'package:project2/pageSwap.dart';
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
        home: Screen1(),
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

// import 'package:flutter/material.dart';
// import 'package:project2/screen2.dart';
// import 'package:project2/screen3.dart';
// import 'package:project2/screen4.dart';

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(
//         title: Text('Expandable PageView Example'),
//       ),
//       body: ExpandablePageView(),
//     ),
//   ));
// }

// class ExpandablePageView extends StatefulWidget {
//   const ExpandablePageView({
//     super.key,
//   });

//   @override
//   _ExpandablePageViewState createState() => _ExpandablePageViewState();
// }

// class _ExpandablePageViewState extends State<ExpandablePageView> {
//   late PageController _pageController;
//   late List<double> _heights;
//   int _currentPage = 0;
//   bool isEsignButtonClicked = true;
//   double get _currentHeight => _heights[_currentPage];

//   @override
//   void initState() {
//     _heights = pages.map((e) => 0.0).toList();
//     super.initState();
//     _pageController = PageController()
//       ..addListener(() {
//         final _newPage = _pageController.page?.round();
//         if (_currentPage != _newPage) {
//           setState(() => _currentPage = _newPage!);
//         }
//       });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   List pages = [
//     Container(
//       height: 500,
//       color: Colors.blue,
//       child: Center(
//         child: Text('Page 1'),
//       ),
//     ),
//     Container(
//       height: 300,
//       color: Colors.green,
//       child: Center(
//         child: Text('Page 2'),
//       ),
//     ),
//     Container(
//       height: 200,
//       color: Colors.red,
//       child: Center(
//         child: Text('Page 3'),
//       ),
//     ),
//   ];
//   int numberOfPages = 3;
//   int? currentPage = 0;
//   final controller = PageController();
//   void goToNextPage() {
//     if (currentPage! < numberOfPages) {
//       if (currentPage! >= 0) {
//         controller.nextPage(
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//         currentPage = currentPage! + 1;
//         setState(() {});
//       }
//     }
//   }

//   void goToPreviousPage() {
//     if (currentPage! > 0) {
//       controller.previousPage(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//       currentPage = currentPage! - 1;
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         TweenAnimationBuilder<double>(
//           curve: Curves.easeInOutCubic,
//           duration: const Duration(milliseconds: 100),
//           tween: Tween<double>(begin: _heights[0], end: _currentHeight),
//           builder: (context, value, child) =>
//               SizedBox(height: value, child: child),
//           child: PageView(
//             controller: _pageController,
//             children: _sizeReportingChildren,
//           ),
//         ),
//         // ElevatedButton(onPressed: () {}, child: Text('hello'))
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Visibility(
//               visible: (currentPage! >= 0
//                   // && currentPage! < pages.length - 1
//                   ),
//               child: ElevatedButton(
//                 onPressed: (currentPage! > 0)
//                     ? goToPreviousPage
//                     : () {
//                         Navigator.pop(context);
//                       },
//                 child: const Text('Back'),
//               ),
//             ),
//             Visibility(
//               visible: currentPage! < pages.length,
//               child: ElevatedButton(
//                 onPressed: currentPage == pages.length - 1
//                     ? () {
//                         //Navigate to Next Page
//                       }
//                     : goToNextPage,
//                 child:
//                     Text(currentPage == pages.length - 1 ? 'Finish' : 'Next'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   List<Widget> get _sizeReportingChildren => pages
//       .asMap()
//       .map(
//         (index, child) => MapEntry(
//           index,
//           OverflowBox(
//             minHeight: 0,
//             maxHeight: double.infinity,
//             alignment: Alignment.topCenter,
//             child: SizeReportingWidget(
//               onSizeChange: (size) =>
//                   setState(() => _heights[index] = size.height),
//               key: Key('1'),
//               child: child,
//             ),
//           ),
//         ),
//       )
//       .values
//       .toList();
// }

// class SizeReportingWidget extends StatefulWidget {
//   final Widget child;
//   final ValueChanged<Size> onSizeChange;

//   const SizeReportingWidget({
//     required Key key,
//     required this.child,
//     required this.onSizeChange,
//   }) : super(key: key);

//   @override
//   _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
// }

// class _SizeReportingWidgetState extends State<SizeReportingWidget> {
//   Size _oldSize = Size.zero; // Initialize with an initial value.

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
//     return widget.child;
//   }

//   void _notifySize() {
//     final size = context?.size;
//     if (_oldSize != size) {
//       _oldSize = size ??
//           Size.zero; // Update with the new size or keep it as Size.zero.
//       widget.onSizeChange(size!);
//     }
//   }
// }
