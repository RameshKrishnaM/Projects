import 'package:flutter/material.dart';

class TextButtonWidget extends StatefulWidget {
  const TextButtonWidget(
      {super.key,
      required this.buttonName,
      required this.buttonFunction,
      required this.fontStyle});
  final String buttonName;
  final VoidCallback buttonFunction;
  final TextStyle fontStyle;
  @override
  State<TextButtonWidget> createState() => _TextButtonWidgetState();
}

class _TextButtonWidgetState extends State<TextButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        
        InkWell(       
          splashColor:const Color.fromARGB(255, 161, 196, 241),            
          onTap: widget.buttonFunction,
          child: Text(
            widget.buttonName,
            style: widget.fontStyle,
          ),
        ),
      ],
    );
  }
}
