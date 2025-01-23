import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../API call/api_call.dart';
import "../Route/route.dart" as route;

class LoadImage extends StatefulWidget {
  final String fileTitle;
  final data;
  final String? fileName;
  const LoadImage(
      {key, required this.fileTitle, required this.data, this.fileName})
      : super(key: key);

  @override
  State<LoadImage> createState() => _LoadImageState();
}

class _LoadImageState extends State<LoadImage> {
  @override
  void initState() {
    widget.data is String ? fetchImage() : isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
    super.initState();
  }

  List? file;
  bool isLoading = true;
  fetchImage() async {
    file = await fetchFile(context: context, id: widget.data, list: true);
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : widget.data is Uint8List
            ? GestureDetector(
                child: Image.memory(
                  widget.data,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/images/img.svg",
                        width: 45.0,
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(context, route.previewImage, arguments: {
                    "title": widget.fileTitle,
                    "data": widget.data,
                    "fileName": widget.fileName
                  });
                },
              )
            : file != null && file!.isNotEmpty
                ? GestureDetector(
                    child: Image.memory(
                      file![1],
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "assets/images/img.svg",
                            width: 45.0,
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, route.previewImage,
                          arguments: {
                            "title": widget.fileTitle,
                            "data": file![1],
                            "fileName": file![0]
                          });
                    },
                  )
                : Center(
                    child: Text("no image"),
                  );
  }
}
