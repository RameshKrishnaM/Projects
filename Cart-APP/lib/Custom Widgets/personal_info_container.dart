import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PersonalInfoContainer extends StatefulWidget {
  final String title;
  final String subtitle;

  final String? svgImage;
  final String? pngImage;
  final VoidCallback onTap;
  const PersonalInfoContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.svgImage,
    this.pngImage,
  });

  @override
  State<PersonalInfoContainer> createState() => _PersonalInfoContainerState();
}

class _PersonalInfoContainerState extends State<PersonalInfoContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        width: 314,
        height: 70,
        decoration: BoxDecoration(
            border: Border.all(
                width: 1.0, color: const Color.fromRGBO(102, 98, 98, 1)),
            borderRadius: BorderRadius.circular(7),
            color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.svgImage != null
                    ? SvgPicture.asset(
                        "assets/images/${widget.svgImage}.svg",
                        width: 15.0,
                        height: 15.0,
                      )
                    : Image.asset(
                        "assets/images/${widget.pngImage}.png",
                        width: 15.0,
                        height: 15.0,
                      ),
                const SizedBox(
                  width: 5.0,
                ),
                Text(widget.title,
                    style: const TextStyle(
                      color: Color.fromRGBO(102, 98, 98, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(widget.subtitle,
                style: const TextStyle(
                  color: Color.fromRGBO(102, 98, 98, 1),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ))
          ],
        ),
      ),
    );
  }
}
