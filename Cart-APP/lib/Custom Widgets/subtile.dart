import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Subtile extends StatefulWidget {
  final String content;
  final String? percentage;
  final String? relationShip;
  final Function Ontap;
  final deleteFunc;
  final bool? isDisable;
  const Subtile({
    required this.Ontap,
    required this.content,
    this.deleteFunc,
    super.key,
    this.isDisable,
    this.percentage,
    this.relationShip,
  });

  @override
  State<Subtile> createState() => _SubtileState();
}

class _SubtileState extends State<Subtile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.Ontap();
      },
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.30,
              color: widget.isDisable ?? false
                  ? Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .color!
                      .withOpacity(0.4)
                  : widget.deleteFunc == null
                      ? Theme.of(context).textTheme.bodyMedium!.color ??
                          const Color(0xFF32BA7C)
                      : const Color(0xFF32BA7C),
            ),
            borderRadius: BorderRadius.circular(6.52),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 25,
            ),
            SvgPicture.asset(
                'assets/images/${widget.isDisable ?? false ? "activeperson" : widget.deleteFunc == null ? "blackperson" : "greenperson"}.svg'),
            const SizedBox(
              width: 5,
            ),
            Expanded(
                child: Row(
              children: [
                Flexible(
                  child: Text(
                      widget.deleteFunc == null
                          ? widget.content
                          : widget.content.split(" ")[0],
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            height: 1,
                            fontSize: 14,
                            color: widget.isDisable ?? false
                                ? Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withOpacity(0.8)
                                : widget.deleteFunc == null
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color
                                    : const Color(0xFF32BA7C),
                          )),
                ),
                Text(
                    widget.relationShip != null
                        ? " (${widget.relationShip})"
                        : "",
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          height: 1,
                          fontSize: 14,
                          color: const Color(0xFF32BA7C),
                        )),
                Text(
                    widget.percentage != null ? " (${widget.percentage}%)" : "",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        height: 1,
                        fontSize: 15,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color!
                            .withOpacity(0.7),
                        fontWeight: FontWeight.w700)),
              ],
            )),
            widget.deleteFunc == null
                ? IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.chevron_right_rounded,
                        color: widget.isDisable ?? false
                            ? Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withOpacity(0.4)
                            : Theme.of(context).textTheme.bodyMedium!.color))
                : IconButton(
                    onPressed: () {
                      openAlertBox(
                          context: context,
                          content:
                              "Do you want Delete the ${widget.content} Details?",
                          onpressedButton1: () {
                            Navigator.pop(context);
                            widget.deleteFunc();
                          });
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Color.fromARGB(255, 212, 101, 93),
                    ),
                  ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ),
    );
  }
}
