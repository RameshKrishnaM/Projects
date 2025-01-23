import 'package:flutter/material.dart';
import 'package:project2/screen2.dart';
import 'package:project2/screen3.dart';
import 'package:project2/screen4.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final controller = PageController();
  int numberOfPages = 3;
  int currentPage = 0;
  List pages = [
    const Screen4(),
    const Screen2(),
    const Screen3(),
  ];
  late List<double> _heights;
  @override
  void initState() {
    _heights = pages.map((e) => 0.0).toList();
    super.initState();
  }

  bool isEsignButtonClicked = true;
  void goToNextPage() {
    if (currentPage < numberOfPages) {
      if (currentPage >= 0 || (currentPage == 1 && isEsignButtonClicked)) {
        controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        currentPage = currentPage + 1;
        setState(() {});
      }
    }
  }

  double get _currentHeight => _heights[currentPage];
  void goToPreviousPage() {
    if (currentPage > 0) {
      controller.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      currentPage = currentPage - 1;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            TweenAnimationBuilder(
              curve: Curves.easeInOutCubic,
              duration: const Duration(milliseconds: 100),
              tween: Tween<double>(begin: _heights[0], end: _currentHeight),
              builder: (context, value, child) =>
                  SizedBox(height: value, child: child),
              child: PageView(
                controller: controller,
                children: pages
                    .asMap()
                    .map(
                      (index, child) => MapEntry(
                        index,
                        OverflowBox(
                          minHeight: 0,
                          maxHeight: double.infinity,
                          alignment: Alignment.topCenter,
                          child: SizeReportingWidget(
                            onSizeChange: (size) =>
                                setState(() => _heights[index] = size.height),
                            child: child,
                          ),
                        ),
                      ),
                    )
                    .values
                    .toList(),
              ),
            ),
            // PageView.builder(
            //   controller: controller,
            //   physics: const NeverScrollableScrollPhysics(),
            //   itemCount: numberOfPages,
            //   onPageChanged: (index) {
            //     currentPage = index;
            //   },
            //   itemBuilder: (context, index) => pages[index],
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: (currentPage >= 0
                      // && currentPage! < pages.length - 1
                      ),
                  child: ElevatedButton(
                    onPressed: (currentPage > 0)
                        ? goToPreviousPage
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text('Back'),
                  ),
                ),
                Visibility(
                  visible: currentPage < pages.length,
                  child: ElevatedButton(
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

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  final GlobalKey _key = GlobalKey();
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return Container(
      key: _key,
      child: widget.child,
    );
  }

  void _notifySize() {
    try {
      if (mounted) {
        final size = context.size;
        if (size != null && _oldSize != size) {
          _oldSize = size;
          widget.onSizeChange(size);
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
