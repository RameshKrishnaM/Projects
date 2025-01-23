import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:projectdemo2/widgets/mycolor.dart';

class MyCropImage extends StatefulWidget {
  final String image;
  final Function(Image? croppedImage) onImageCropped;
  const MyCropImage({
    super.key,
    required this.image,
    required this.onImageCropped,
  });

  @override
  State<MyCropImage> createState() => _MyCropImageState();
}

class _MyCropImageState extends State<MyCropImage> {
  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bgcolor1,
                // bgcolor2,
                bgcolor3,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Center(
            child: CropImage(
              controller: controller,
              image: Image.network(widget.image),
              paddingSize: 25.0,
              alwaysMove: true,
            ),
          ),
        ),
        bottomNavigationBar: _buildButtons(),
      );

  Widget _buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.rotation = CropRotation.up;
              controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              controller.aspectRatio = 1.0;
            },
          ),
          IconButton(
            icon: const Icon(Icons.aspect_ratio),
            onPressed: _aspectRatios,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
            onPressed: _rotateLeft,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
            onPressed: _rotateRight,
          ),
          TextButton(
            onPressed: () {
              finished();
              setState(() {});
            },
            child: const Text('Done'),
          ),
        ],
      );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('free'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value == -1 ? null : value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<void> finished() async {
    final croppedImage = await controller.croppedImage();
    Navigator.pop(context);
    return widget.onImageCropped(croppedImage);
  }
}
