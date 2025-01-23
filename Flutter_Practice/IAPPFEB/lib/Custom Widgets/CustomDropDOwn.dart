import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomSearchDropDown extends StatefulWidget {
  final TextEditingController controller;
  final List list;
  final String labelText;
  final String hintText;
  final bool isIcon;
  final onChange;
  final bool filled;
  final bool? autoValidate;
  final bool iscountry;
  CustomSearchDropDown(
      {super.key,
      required this.controller,
      required this.list,
      required this.labelText,
      required this.hintText,
      this.onChange,
      this.isIcon = false,
      this.filled = false,
      this.autoValidate,
      this.iscountry = false});

  @override
  State<CustomSearchDropDown> createState() => _CustomSearchDropDownState();
}

class _CustomSearchDropDownState extends State<CustomSearchDropDown> {
  TextEditingController con = TextEditingController();
  bool isDropdownOpen = false;
  @override
  Widget build(BuildContext context) {
    // print(widget.list);
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          isDropdownOpen = hasFocus;
        });
      },
      child: TypeAheadField(
        controller: widget.controller,
        suggestionsCallback: (pattern) async {
          // print(widget.list.where((item) {
          //   return item.toLowerCase().contains(pattern.toLowerCase());
          // }).toList());
          return widget.list.where((item) {
            return item.toLowerCase().contains(pattern.toLowerCase());
          }).toList();
        },
        itemBuilder: (context, suggestion) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              suggestion.toString(),
              style: con.text == suggestion
                  ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)
                  : Theme.of(context).textTheme.bodyMedium!,
            ),
          );
        },
        builder: (context, controller, focusNode) {
          return TextFormField(
            focusNode: focusNode,
            // textAlign: TextAlign.center,
            autovalidateMode: widget.autoValidate == true
                ? AutovalidateMode.onUserInteraction
                : null,
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
            ],
            onChanged: (value) {
              widget.controller.text = value;
              widget.onChange != null ? widget.onChange(value) : null;
            },
            controller: widget.controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.filled
                  ? Color.fromRGBO(248, 247, 247, 1)
                  : Color.fromRGBO(255, 255, 255, 1),
              hintText: widget.hintText,
              hintStyle: TextStyle(fontSize: 16.0
                  /*   color:Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .color!
                      .withOpacity(0.4) */
                  ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: BorderSide(
                  color: widget.controller.text.isNotEmpty
                      ? Color.fromRGBO(9, 101, 218, 1)
                      : const Color.fromRGBO(
                          195, 195, 195, 1), //9, 101, 218, 1 // Border color
                  width: 1.3, // Border width
                ),
              ),
              suffixIcon: widget.isIcon
                  ? isDropdownOpen
                      ? const Icon(
                          Icons.keyboard_arrow_up,
                          color: Color.fromRGBO(108, 114, 127, 1),
                        )
                      : const Icon(Icons.keyboard_arrow_down,
                          color: Color.fromRGBO(108, 114, 127, 1))
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.iscountry
                    ? "Please enter the valid country name"
                    : "Please enter the valid State name";
              }
              if (!widget.list.any((element) =>
                  element.toString().toUpperCase() == value.toUpperCase())) {
                return widget.iscountry
                    ? "Please enter the valid country name"
                    : "Please enter the valid State name";
              }
              return null;
            },
          );
        },
        itemSeparatorBuilder: (context, index) => Divider(
            thickness: 1.0, color: Theme.of(context).colorScheme.primary),
/* itemBuilder: (context, city) {
return const Column(
children: [
Text("a"),
Text("b"),
Text("c"),
Text("d"),
Text("e"),
],
);
}, */
// hideOnSelect: true,
        onSelected: (suggestion) {
          widget.controller.text = suggestion
              .toString(); //when we select the items it go to the input field
          widget.onChange != null
              ? widget.onChange(suggestion.toString())
              : null;
        },
      ),
      /* TypeAheadField(
        controller: con,
        builder: (context, controller, focusNode) {
          return TextFormField(
            focusNode: focusNode,
            // textAlign: TextAlign.center,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(
                fontFamily: "InterBold",
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
            onChanged: (value) {
              widget.controller.text = value;
            },
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(fontSize: 16.0
                  /*   color:Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .color!
                      .withOpacity(0.4) */
                  ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              suffixIcon: isDropdownOpen
                  ? const Icon(
                      Icons.arrow_drop_up,
                      color: Color.fromRGBO(108, 114, 127, 1),
                    )
                  : const Icon(Icons.arrow_drop_down,
                      color: Color.fromRGBO(108, 114, 127, 1)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter the ${widget.labelText}";
              }
              if (!widget.list.any((element) =>
                  element.toString().toUpperCase() == value.toUpperCase())) {
                return "Please enter the correct ${widget.labelText}";
              }
              return null;
            },
          );
        },
        // offset: const Offset(0, 5),
        // decorationBuilder: (context, child) {
        //   return Material(
        //     type: MaterialType.card,
        //     borderRadius: BorderRadius.circular(10.0),
        //     elevation: 20.0,
        //     child: child,
        //   );
        // },
        suggestionsCallback: (pattern) {
          return widget.list.where((item) {
            return item.toLowerCase().contains(pattern.toLowerCase());
          }).toList();
        },

        // suggestionsCallback: (pattern) {
        //   return widget.list
        //       .where((element) => element
        //           .toString()
        //           .toUpperCase()
        //           .contains(pattern.toUpperCase()))
        //       .toList();
        //   /*  pattern == ""
        //       ? widget.list
        //       : widget.list
        //           .where((element) => element
        //               .toString()
        //               .toUpperCase()
        //               .contains(pattern.toUpperCase()))
        //           .toList(); */
        // },

        // listBuilder: (context, children) {
        //   print("hahha");
        //   print(children);
        //   return Padding(
        //     padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 2.0),
        //     child: Text(
        //       "$children",
        //       style: TextStyle(color: Colors.black),
        //     ),
        //   );
        // },
        itemBuilder: (context, suggestion) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$suggestion"),
          );
          // ListTile(
          //   title:,
          // );
          //  Padding(
          //   padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 2.0),
          //   child: Text(
          //     "$suggestion",
          //     style: TextStyle(color: Colors.black),
          //   ),
          // );
        },
        onSelected: (suggestion) {
          con.text = suggestion;
          /*  if (widget.controller.text != suggestion) {
            widget.controller.text = suggestion;
            // if (widget.onChange != null) {
            //   widget.onChange(true);
            // }
          } */

          //when we select the items it go to the input field
        },
        itemSeparatorBuilder: (context, index) => Divider(
            thickness: 1.0, color: Theme.of(context).colorScheme.primary),
      ), */
    );
  }
}
