import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:ekyc/Service/download_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

import '../API call/api_call.dart';

class ImagePreview extends StatefulWidget {
  final String title;
  final data;
  final String? fileName;

  const ImagePreview(
      {super.key, required this.data, required this.title, this.fileName});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool downloadButtonEnable = false;
  bool fullScreen = false;
  String? fileName;
  Uint8List? data;
  bool isLoading = true;
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black));
    widget.data is String ? fetchImage() : null;

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(0, 71, 255, 0.81)));
    super.dispose();
  }

  fetchImage() async {
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
                if (mounted) {
                  setState(() {});
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 1,
                width: MediaQuery.of(context).size.width * 1,
                child: widget.data is Uint8List
                    ? PhotoView(
                        imageProvider: MemoryImage(widget.data),
                      )
                    : isLoading
                        ? Container(
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator())
                        : data != null
                            ? PhotoView(
                                imageProvider: MemoryImage(data!),
                              )
                            : const SizedBox(),
              ),
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
                            widget.data is Uint8List
                                ? downloadFile(widget.title.replaceAll("/", ""),
                                    widget.data, widget.fileName, context)
                                : downloadFile(
                                    widget.title, data!, fileName, context);
                          },
                          icon: Icon(
                            Icons.download,
                            color: Colors.white,
                          ))
                      : const SizedBox(width: 20.0),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
