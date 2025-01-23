import 'package:flutter/material.dart';

import '../Model/route_model.dart';
import 'custom.dart';
import 'error_message.dart';
import 'loadimage.dart';
import 'video_player.dart';

class IPVPage extends StatefulWidget {
  final String imageId;
  final String videoId;
  final String signatureId;
  final String otp;
  final RouteModel? routeDetails;
  const IPVPage(
      {super.key,
      required this.imageId,
      required this.videoId,
      this.routeDetails,
      required this.otp,
      required this.signatureId});

  @override
  State<IPVPage> createState() => _IPVPageState();
}

class _IPVPageState extends State<IPVPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomStyledContainer(
      child: Column(
        children: [
          ErrorMessageContainer(routeDetails: widget.routeDetails),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        const CustomTitleText(
                          title: 'Selfie Image',
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
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
                            child: widget.imageId == ""
                                ? Container()
                                : LoadImage(
                                    data: widget.imageId,
                                    fileTitle: "ipvImage",
                                  ))
                      ],
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 4,
                    child: widget.videoId.isEmpty
                        ? widget.signatureId != "" &&
                                widget.signatureId.isNotEmpty
                            ? Column(
                                children: [
                                  const CustomTitleText(
                                    title: 'Signature Image',
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
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
                                      child: widget.signatureId == ""
                                          ? Container()
                                          : LoadImage(
                                              data: widget.signatureId,
                                              fileTitle: "ipvImage",
                                            ))
                                ],
                              )
                            : SizedBox()
                        : Column(
                            children: [
                              const CustomTitleText(
                                title: 'Selfie Video',
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Container(
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
                                  child: VideoPlayerInReview(
                                    data: widget.videoId,
                                    otp: widget.otp,
                                  ))
                            ],
                          ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              widget.signatureId != "" &&
                      widget.signatureId.isNotEmpty &&
                      widget.videoId.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              const CustomTitleText(
                                title: 'Signature Image',
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                  // width: 109.20,
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
                                  child: widget.signatureId == ""
                                      ? Container()
                                      : LoadImage(
                                          data: widget.signatureId,
                                          fileTitle: "ipvImage",
                                        ))
                            ],
                          ),
                        ),
                        Expanded(flex: 1, child: SizedBox()),
                        Expanded(flex: 4, child: SizedBox())
                      ],
                    )
                  : SizedBox()
            ],
          ),
        ],
      ),
    );
  }
}
