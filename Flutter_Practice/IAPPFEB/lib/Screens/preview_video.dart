import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

import '../Service/download_file.dart';

class PreviewVideo extends StatefulWidget {
  final File file;
  final String otp;
  const PreviewVideo({super.key, required this.file, required this.otp});

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  VideoPlayerController? _videoController;

  // ChewieController? _chewieController;
  bool isPlay = false;
  bool isLoading = true;
  bool isError = false;
  bool downloadButtonEnable = false;
  bool fullScreen = false;
  String fileName = '';
  // VlcPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    print("file ${widget.file}");
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black));
    List l = widget.file.path.split("/");
    fileName = l[l.length - 1];
    getVideo();
  }

  getVideo() async {
    // _controller = VlcPlayerController.file(widget.file,
    //     hwAcc: HwAcc.full,
    //     autoPlay: true,
    //     options: VlcPlayerOptions(
    //       advanced: VlcAdvancedOptions([
    //         // '--codec=avcodec', // Custom codec option
    //       ]),
    //     ));
    try {
      _videoController = VideoPlayerController.file(
        widget.file,
      );
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.play();
      isPlay = true;
    } catch (e) {
      isError = true;
    }
    if (mounted) {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (isPlay) {
      try {
        _videoController!.pause();
        _videoController?.dispose();
        isPlay = false;
      } catch (e) {}
    }
    // _videoController?.dispose();
    // TODO: implement dispose
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(0, 71, 255, 0.81)));
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Container(
              alignment: Alignment.center, child: CircularProgressIndicator())
          : SafeArea(
              child: InkWell(
                onTap: () {
                  if (isError) {
                    downloadFile("ipvVideo", widget.file.readAsBytesSync(),
                        fileName, context);
                  } else if (isPlay) {
                    _videoController!.pause();
                    isPlay = false;
                  } else {
                    _videoController!.play();
                    isPlay = true;
                  }
                  setState(() {});
                },
                child: Stack(
                  children: [
                    Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 1,
                        // width: MediaQuery.of(context).size.width * 0.9,
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child:
                              // VlcPlayer(
                              //   virtualDisplay: true,
                              //   controller: _controller!,
                              //   aspectRatio: _controller!.value.aspectRatio,
                              //   placeholder:
                              //       Center(child: CircularProgressIndicator()),
                              // ),
                              VideoPlayer(_videoController!),
                        )),
                    Visibility(
                      visible: !isPlay,
                      // replacement: Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.only(top: 15.0),
                      //       child: Text(
                      //         widget.otp.isEmpty ? "" : 'OTP - ${widget.otp}',
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .bodyLarge!
                      //             .copyWith(color: Colors.white),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      child: Container(
                        width: double.infinity,
                        // height: MediaQuery.of(context).size.height * 0.25,
                        color:
                            Colors.transparent, // Colors.grey.withOpacity(0.4),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(
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
                                isError
                                    ? SizedBox(width: 25.0)
                                    : IconButton(
                                        onPressed: () {
                                          downloadFile(
                                              "ipvVideo",
                                              widget.file.readAsBytesSync(),
                                              fileName,
                                              context);
                                        },
                                        icon: const Icon(
                                          Icons.download,
                                          color: Colors.white,
                                        )),
                              ],
                            ),
                            // Text(
                            //   widget.otp.isEmpty ? "" : 'OTP - ${widget.otp}',
                            //   style: Theme.of(context)
                            //       .textTheme
                            //       .bodyLarge!
                            //       .copyWith(color: Colors.white),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !isPlay,
                      child: Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 0.99,
                        width: double.infinity,
                        child: Icon(
                          isError
                              ? Icons.download
                              : isPlay
                                  ? Icons.pause
                                  : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
