import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../API call/api_call.dart';
import '../Model/route_model.dart';
import '../Route/route.dart' as route;
import 'custom.dart';
import 'error_message.dart';
import 'loadimage.dart';

var key = UniqueKey();

class FileUploadContainer extends StatelessWidget {
  final String? chequeLeafId;
  final String? signflag;
  final String? incomeImageId;
  final String? signImageId;
  final String? panImageId;
  final RouteModel? routeDetails;
  final String? proofType;
  FileUploadContainer(
      {super.key,
      this.chequeLeafId,
      this.signflag,
      this.incomeImageId,
      this.signImageId,
      this.panImageId,
      this.routeDetails,
      this.proofType});

  List data = [];

  @override
  Widget build(BuildContext context) {
    data = [
      {"name": "Bank Proof", "imageid": chequeLeafId},
      {"name": "Copy of PAN", "imageid": panImageId},
      {"name": "Signature", "imageid": signflag == "Y" ? signImageId : ""},
      {"name": "Income Proof", "imageid": incomeImageId},
    ];
    List sorteddata =
        data.where((element) => element["imageid"] != "").toList();

    return CustomStyledContainer(
      child: Column(
        children: [
          ErrorMessageContainer(routeDetails: routeDetails),
          Wrap(
            spacing: 20,
            children: sorteddata
                .map((e) => SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.5 - 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            e["name"],
                            maxLines: 3,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  color: const Color.fromRGBO(195, 195, 195, 1),
                                  fontSize: 15.0,
                                ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 145.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3.0,
                                    blurRadius: 5.0,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: LoadingWidget(
                                id: e["imageid"],
                                title: e["name"],
                              ))
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(
            height: 15.0,
          ),
          Visibility(
            visible: proofType != null && proofType!.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Proof Type : ",
                  style: TextStyle(
                    color: Color.fromRGBO(195, 195, 195, 1),
                    fontSize: 15.0,
                  ),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Text(
                    proofType ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 15.0, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFileUpload extends StatelessWidget {
  final String title1;
  final String title2;
  final String? contentId1;
  final String? contentId2;
  const CustomFileUpload(
      {super.key,
      required this.title1,
      required this.title2,
      required this.contentId1,
      required this.contentId2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: contentId1!.isNotEmpty,
          child: Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTitleText(
                  title: title1,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 145.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3.0,
                          blurRadius: 5.0,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: contentId1!.isEmpty
                        ? Container()
                        : LoadingWidget(
                            id: contentId1!,
                            title: title1,
                          ))
              ],
            ),
          ),
        ),
        Visibility(
            visible: contentId1!.isNotEmpty,
            child: const Expanded(flex: 1, child: SizedBox())),
        Expanded(
          flex: 4,
          child: contentId2!.isEmpty
              ? const SizedBox()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTitleText(
                      title: title2,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 145.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3.0,
                              blurRadius: 5.0,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: contentId2!.isEmpty
                            ? Container()
                            : LoadingWidget(
                                id: contentId2!,
                                title: title2,
                              ))
                  ],
                ),
        ),
        Visibility(
            visible: contentId1!.isEmpty,
            child: const Expanded(flex: 1, child: SizedBox())),
        Visibility(
            visible: contentId1!.isEmpty,
            child: const Expanded(flex: 4, child: SizedBox()))
      ],
    );
  }
}

class LoadingWidget extends StatefulWidget {
  final String title;
  final String id;
  const LoadingWidget({super.key, required this.title, required this.id});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  bool isLoading = true;
  Uint8List? bytes;
  String? fileName;
  @override
  void initState() {
    super.initState();
    fetchFileData();
  }

  fetchFileData() async {
    if (widget.id.isEmpty) {
      isLoading = false;
      setState(() {});
      return;
    }
    try {
      var response =
          await fetchFile(context: context, id: widget.id, list: true);
      if (response != null) {
        fileName = response[0];
        bytes = response[1];
      }
    } catch (e) {}
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (widget.id.isEmpty) {
      return const Center(child: Text('File Not Found'));
    } else if (fileName is String && fileName!.toLowerCase().endsWith('.pdf')) {
      return PdfViewerWithName(
          pdfPath: fileName!, id: bytes!, title: widget.title);
    } else if (fileName is String) {
      return LoadImage(
          data: bytes, fileTitle: widget.title, fileName: fileName!);
    } else {
      return const Center(child: Text(''));
    }
  }
}

Widget getContentWidget(content, bytes, title) {
  if (content is String && content.toLowerCase().endsWith('.pdf')) {
    return PdfViewerWithName(
      pdfPath: content,
      id: bytes,
      title: title,
    );
  } else if (content is String) {
    return LoadImage(
      data: bytes,
      fileTitle: title,
      fileName: content,
    );
  } else {
    return const Text('Unsupported file type');
  }
}

class PdfViewerWithName extends StatelessWidget {
  final String pdfPath;
  final Uint8List id;
  final String title;

  const PdfViewerWithName({
    Key? key,
    required this.pdfPath,
    required this.id,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route.previewPdf,
          arguments: {"title": title, "data": id, "fileName": pdfPath}),
      child: Container(
        margin: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/images/pdf_logo.svg",
              width: 55.0,
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
