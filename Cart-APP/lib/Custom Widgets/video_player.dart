import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import '../API call/api_call.dart';
import '../Route/route.dart' as route;

class VideoPlayerInReview extends StatefulWidget {
  final String? fileName;
  final String otp;
  final data;
  const VideoPlayerInReview(
      {key, required this.data, this.fileName, required this.otp})
      : super(key: key);

  @override
  State<VideoPlayerInReview> createState() => _VideoPlayerInReviewState();
}

class _VideoPlayerInReviewState extends State<VideoPlayerInReview> {
  VideoPlayerController? _videoController;
  File? tempFile;
  bool isPlay = false;
  bool isLoading = true;
  bool isError = false;
  bool isWorking = false;
  @override
  void initState() {
    super.initState();
    getVideo();
  }

  getVideo() async {
    try {
      var response = widget.data is String && widget.data.toString().isNotEmpty
          ? await fetchFile(context: context, id: widget.data, list: true)
          : await widget.data;

      if (response != null && widget.data.toString().isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        tempFile = File(
            '${tempDir.path}/${widget.data is String ? response[0] ?? "IPV_video.mp4" : widget.fileName ?? "IPV_video.mp4"}');
        await tempFile!
            .writeAsBytes(widget.data is String ? response[1] : response);

        _videoController = VideoPlayerController.file(
          tempFile!,
        );

        await _videoController!.initialize();
        await _videoController!.setLooping(true);
      }
    } catch (e) {
      isError = true;
    }
    if (mounted) {
      isLoading = false;
      setState(() {});
    }
  }

  playVideo() async {}

  deleteTempFile() async {
    try {
      _videoController?.dispose();
      if (await tempFile?.exists() ?? false) {
        await tempFile!.delete();
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    deleteTempFile();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_videoController != null &&
                _videoController!.value.isInitialized) ||
            isError
        ? InkWell(
            onTap: () => Navigator.pushNamed(context, route.previewVideo,
                arguments: {"file": tempFile, "otp": widget.otp}),
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_videoController!),
                Icon(
                  isPlay ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                )
              ],
            ),
          )
        : Container(
            alignment: Alignment.center,
            child:
                isLoading == true ? CircularProgressIndicator() : SizedBox());
  }
}
