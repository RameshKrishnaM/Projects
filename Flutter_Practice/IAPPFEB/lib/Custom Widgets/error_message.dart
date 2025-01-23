import 'package:dotted_border/dotted_border.dart';
import 'package:ekyc/Model/route_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ErrorMessageContainer extends StatefulWidget {
  final RouteModel? routeDetails;
  final List? message;
  const ErrorMessageContainer({super.key, this.routeDetails, this.message});

  @override
  State<ErrorMessageContainer> createState() => _ErrorMessageContainerState();
}

class _ErrorMessageContainerState extends State<ErrorMessageContainer> {
  bool showErr = false;
  List? message;
  @override
  void initState() {
    // TODO: implement initState
    widget.routeDetails != null && widget.routeDetails!.message != null
        ? message = widget.routeDetails!.message
        : widget.message != null
            ? message = widget.message
            : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return message != null && message!.isNotEmpty
        //  (widget.routeDetails != null &&
        //             widget.routeDetails!.message != null &&
        //             widget.routeDetails!.message!.isNotEmpty) ||
        //         (widget.message != null && widget.message!.isNotEmpty)
        //  widget.routeDetails == null ||
        //         widget.routeDetails!.message == null ||
        //         widget.routeDetails!.message!.isEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: DottedBorder(
              color: Colors.red,
              padding: EdgeInsets.zero,
              borderType: BorderType.RRect,
              radius: const Radius.circular(6),
              dashPattern: [5, 3],
              child: Container(
                width: widget.message != null
                    ? MediaQuery.of(context).size.width - 60
                    : MediaQuery.of(context).size.width - 80,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    gradient: LinearGradient(colors: [
                      Colors.red,
                      Colors.red.withOpacity(0.15),
                    ], stops: [
                      0,
                      0.02
                    ])),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 5.0),
                        Text(
                          "Reject Reason",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            child: Text(
                              showErr ? "close" : "View",
                              style: TextStyle(color: Colors.blue),
                            ),
                            onTap: () {
                              showErr = !showErr;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {});
                              });
                            },
                          ),
                        ))
                      ],
                    ),
                    Visibility(
                        visible: showErr,
                        child: Column(
                          children: [
                            SizedBox(height: 5.0),
                            ...message!
                                .map((message) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 15.0),
                                          Container(
                                            margin: EdgeInsets.only(top: 10.0),
                                            height: 5.0,
                                            width: 5.0,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle),
                                          ),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                            child: Text(
                                              "$message",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        ],
                                      ),
                                    ))
                                .toList()
                          ],
                        ))
                  ],
                ),
              ),
            ),
          )
        : SizedBox();
  }
}
