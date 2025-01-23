import 'package:flutter/material.dart';

class SearchFeild extends StatefulWidget {
  const SearchFeild({
    Key? key,
    required this.visible,
    required this.onChange,
  }) : super(key: key);
  final bool visible;
  final Function onChange;
  @override
  State<SearchFeild> createState() => SearchFeildState();
}

class SearchFeildState extends State<SearchFeild> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 8.0),
      child: SingleChildScrollView(
        child: Visibility(
          visible: widget.visible,
          child: SizedBox(
            // color: Colors.red,
            height: 38,
            child: TextField(
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  labelText: 'Search',
                  labelStyle: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(156, 155, 173, 1)),
                  suffixIcon: Icon(Icons.search_rounded)),
              onChanged: (value) => widget.onChange(value),
            ),
          ),
        ),
      ),
    );
  }
}
