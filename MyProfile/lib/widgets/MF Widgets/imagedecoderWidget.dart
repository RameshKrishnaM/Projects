import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageLoader extends StatefulWidget {
  final String loadingImg;

  const ImageLoader({required this.loadingImg, Key? key}) : super(key: key);

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader>
    with AutomaticKeepAliveClientMixin<ImageLoader> {
  Future<bool>? _imageFuture;
  Image? _cachedImage;

  @override
  void didUpdateWidget(covariant ImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the image URL or data has changed
    if (widget.loadingImg != oldWidget.loadingImg) {
      _cachedImage = null; // Clear the previous image cache
      if (widget.loadingImg.startsWith('http') ||
          widget.loadingImg.startsWith('https')) {
        _imageFuture = _checkImageUrl(widget.loadingImg);
      } else if (widget.loadingImg.contains(";base64,")) {
        _loadBase64Image();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.loadingImg.startsWith('http') ||
        widget.loadingImg.startsWith('https')) {
      _imageFuture = _checkImageUrl(widget.loadingImg);
    } else if (widget.loadingImg.contains(";base64,")) {
      _loadBase64Image();
    }
  }

  void _loadBase64Image() {
    try {
      final base64String = widget.loadingImg.split(";base64,").last;
      final bytes = base64Decode(base64String);
      setState(() {
        _cachedImage = Image.memory(
          bytes,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(); // Placeholder for errors
          },
          fit: BoxFit.cover,
        );
      });
    } catch (e) {
      setState(() {
        _cachedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build for keep-alive

    if (_cachedImage != null) {
      return _cachedImage!;
    }

    if (widget.loadingImg.startsWith('http') ||
        widget.loadingImg.startsWith('https')) {
      return FutureBuilder<bool>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!) {
              return Image.network(
                widget.loadingImg,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(); // Placeholder for errors
                },
                fit: BoxFit.cover,
              );
            } else {
              return const SizedBox(); // Placeholder if URL check fails
            }
          } else {
            return const SizedBox(); // Optionally show a loader
          }
        },
      );
    }

    return const SizedBox(); // Display nothing for invalid image format
  }

  Future<bool> _checkImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  bool get wantKeepAlive => true; // Keep the widget alive
}
