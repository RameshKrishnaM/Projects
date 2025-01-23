import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FilledPersonalInfoContainer extends StatefulWidget {
  final String title2;
  final String subtitle2;
  final VoidCallback onTap;
  const FilledPersonalInfoContainer({
    super.key,
    required this.onTap,
    required this.title2,
    required this.subtitle2,
  });

  @override
  State<FilledPersonalInfoContainer> createState() =>
      _FilledPersonalInfoContainerState();
}

class _FilledPersonalInfoContainerState
    extends State<FilledPersonalInfoContainer> {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10.0,
              ),
              SvgPicture.asset(
                "assets/images/done.svg",
                width: 15.0,
                height: 15.0,
              ),
              const SizedBox(
                width: 20.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title2,
                      style: const TextStyle(
                        color: Color.fromRGBO(102, 98, 98, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(widget.subtitle2,
                      style: const TextStyle(
                        color: Color.fromRGBO(102, 98, 98, 1),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ))
                ],
              )
            ],
          )),
    );
  }
}
