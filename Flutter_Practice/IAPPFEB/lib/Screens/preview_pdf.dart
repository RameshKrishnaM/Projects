import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdfx/pdfx.dart';
import '../API call/api_call.dart';
import '../Custom Widgets/custom_snackBar.dart';
import '../Service/download_file.dart';

class PDFPreview extends StatefulWidget {
  final String title;
  final data;
  final String? fileName;

  const PDFPreview(
      {super.key, required this.data, required this.title, this.fileName});

  @override
  State<PDFPreview> createState() => _PDFPreviewState();
}

class _PDFPreviewState extends State<PDFPreview> {
  bool downloadButtonEnable = false;
  bool fullScreen = false;
  bool isLoading = true;
  String? fileName;
  Uint8List? data;
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black));
    widget.data is String ? fetchPDF() : null;
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(0, 71, 255, 0.81)));
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: SystemUiOverlay.values);
    super.dispose();
  }

  fetchPDF() async {
    try {
      var response =
          await fetchFile(context: context, id: widget.data, list: true);
      if (response != null) {
        fileName = response[0];
        data = response[1];
        downloadButtonEnable = true;
      }
    } catch (e) {
      showSnackbar(context, e.toString(), Colors.red);
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InkWell(
              onTap: () {
                fullScreen = !fullScreen;

                // if (mounted) {
                //   setState(() {});
                // }
              },
              child: Container(
                  height: MediaQuery.of(context).size.height * 1,
                  width: MediaQuery.of(context).size.width * 1,
                  child: widget.data is Uint8List
                      ? PdfView(
                          scrollDirection: Axis.vertical,
                          controller: PdfController(
                              document: PdfDocument.openData(widget.data!)),
                        )
                      : isLoading
                          ? Container(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator())
                          : data != null
                              ? PdfView(
                                  scrollDirection: Axis.vertical,
                                  controller: PdfController(
                                      document: PdfDocument.openData(data!)),
                                )
                              //  PDFView(
                              //     // filePath: snapshot.data!,
                              //     pdfData: data,
                              //     enableSwipe: true,
                              //     swipeHorizontal: false,
                              //     autoSpacing: false,
                              //     pageFling: false,
                              //   )
                              : SizedBox()),
            ),
          ),
          Visibility(
            visible: !fullScreen,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.06,
              color: Colors.black.withOpacity(0.25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                  Text(
                    'Preview',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                  widget.data is Uint8List || downloadButtonEnable == true
                      ? IconButton(
                          onPressed: () {
                            // if (widget.data || data == null) return;
                            widget.data is Uint8List
                                ? downloadFile(widget.title, widget.data,
                                    widget.fileName, context)
                                : downloadFile(
                                    widget.title, data!, fileName, context);
                            // Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.download,
                            color: Colors.white,
                          ))
                      : SizedBox(width: 20.0),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
