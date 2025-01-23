import 'dart:io';

import 'package:ekyc/Screens/signup.dart';
import 'package:flutter/material.dart';
import '../API call/api_call.dart';
import "../Route/route.dart" as route;

class CustomUpload extends StatefulWidget {
  final String title;
  final String subTitle;
  final dropDown;
  final String? fileName;
  final file;
  final onTap;
  final bool showError;
  const CustomUpload({
    super.key,
    required this.title,
    required this.subTitle,
    this.dropDown,
    required this.fileName,
    required this.file,
    required this.onTap,
    required this.showError,
  });

  @override
  State<CustomUpload> createState() => _CustomUploadState();
}

class _CustomUploadState extends State<CustomUpload> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.title != "Income Proof"
          ? BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: const Color.fromRGBO(9, 101, 218, 1),
              ),
              borderRadius: BorderRadius.circular(7.0),
            )
          : BoxDecoration(),
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            "File format should be (*.jpg,*.jpeg,*.png${widget.title != "Signature" ? ",*.pdf" : ""}) and file size should be less than 5MB",
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.subTitle,
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              if (MediaQuery.of(context).size.width >= 350) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        textStyle: const MaterialStatePropertyAll(
                          TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1.3,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        backgroundColor: MaterialStatePropertyAll(
                          widget.file != null &&
                                  widget.file.toString().isNotEmpty
                              ? Colors.green
                              : Color.fromRGBO(190, 215, 246, 1),
                        ),
                      ),
                      onPressed: widget.onTap,
                      child: Row(
                        children: [
                          Icon(
                            Icons.file_upload_outlined,
                            color: (widget.file != null &&
                                    widget.file.toString().isNotEmpty)
                                ? Colors.white
                                : Colors.black,
                            size: 20.0,
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            widget.file != null &&
                                    widget.file.toString().isNotEmpty
                                ? 'Re upload'
                                : 'Upload',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: (widget.file != null &&
                                            widget.file.toString().isNotEmpty)
                                        ? Colors.white
                                        : Color.fromARGB(255, 70, 68, 68),
                                    fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.showError,
                      child: Text(
                        "Required",
                        style: const TextStyle(
                            color: Color.fromRGBO(176, 0, 32, 1),
                            fontSize: 10.0),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (MediaQuery.of(context).size.width < 350) ...[
            const SizedBox(
              height: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    textStyle: const MaterialStatePropertyAll(
                      TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.3,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: MaterialStatePropertyAll(
                      widget.file != null && widget.file.toString().isNotEmpty
                          ? Colors.green
                          : Color.fromRGBO(190, 215, 246, 1),
                    ),
                  ),
                  onPressed: widget.onTap,
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_upload_outlined,
                        color: (widget.file != null &&
                                widget.file.toString().isNotEmpty)
                            ? Colors.white
                            : Colors.black,
                        size: 20.0,
                      ),
                      const SizedBox(width: 5.0),
                      Text(
                        widget.file != null && widget.file.toString().isNotEmpty
                            ? 'Re upload'
                            : 'Upload',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: (widget.file != null &&
                                    widget.file.toString().isNotEmpty)
                                ? Colors.white
                                : Color.fromARGB(255, 70, 68, 68),
                            fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.showError,
                  child: Text(
                    "Required",
                    style: const TextStyle(
                        color: Color.fromRGBO(176, 0, 32, 1), fontSize: 10.0),
                  ),
                ),
              ],
            ),
          ],
          if (widget.dropDown != null) ...[
            SizedBox(height: 10.0),
            widget.dropDown
          ],
          if (widget.file != null && widget.file.toString().isNotEmpty) ...[
            const SizedBox(height: 10.0),
            InkWell(
              child: Text(
                "Preview ${widget.fileName!} file",
                style: TextStyle(color: Color.fromRGBO(50, 169, 220, 1)),
              ),
              onTap: () async {
                if (widget.file is File) {
                  Navigator.pushNamed(
                      context,
                      widget.file!.path.toLowerCase().endsWith(".pdf")
                          ? route.previewPdf
                          : route.previewImage,
                      arguments: {
                        "title": widget.fileName,
                        "data": await widget.file.readAsBytes(),
                        "fileName": widget.file!.path
                      });
                } else {
                  loadingAlertBox(context);
                  try {
                    var response = await fetchFile(
                        context: context, id: widget.file, list: true);
                    Navigator.pop(context);
                    if (response != null) {
                      Navigator.pushNamed(
                          context,
                          response[0].toLowerCase().endsWith(".pdf")
                              ? route.previewPdf
                              : route.previewImage,
                          arguments: {
                            "title": widget.fileName,
                            "data": response[1],
                            "fileName": response[0]
                          });
                    }
                  } catch (e) {}
                }
              },
            )
          ],
        ],
      ),
    );
  }
}
