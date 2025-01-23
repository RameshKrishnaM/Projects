import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class MyBottomSheet extends StatefulWidget {
  var hniFunc;
  var indFunc;
  int selectedvalue;
  String cateChangeText;
  String cateInfoText;
  String indtext;
  String indCode;
  String hnitext;
  String hniCode;
  String indRangText;
  String hniRangText;

  // int selectedvalue;
  MyBottomSheet({
    super.key,
    required this.hniFunc,
    required this.indFunc,
    required this.selectedvalue,
    required this.cateChangeText,
    required this.cateInfoText,
    required this.indtext,
    required this.hnitext,
    required this.indCode,
    required this.hniCode,
    required this.indRangText,
    required this.hniRangText,

    // required this.selectedvalue
  });
  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  int? _selectedValue;
  @override
  void initState() {
    // _selectedValue = widget.selectedvalue;
    // TODO: implement initState
    _selectedValue = widget.selectedvalue;
    super.initState();
  }
  // Default selected value

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.red,
      //   borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(20.0),
      //     topRight: Radius.circular(20.0),
      //   ),
      // ),
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Wrap(
        children: <Widget>[
          ListTile(
            title: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    // widget.cateChangeText,
                    softWrap: true,
                    'Apply as ',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            titleAlignment: ListTileTitleAlignment.center,
            // trailing: Expanded(child: SizedBox()),
          ),
          RadioListTile(
            activeColor: Provider.of<NavigationProvider>(context).themeMode ==
                    ThemeMode.light
                ? appPrimeColor
                : primaryGreenColor,
            subtitle: Text(
              widget.indRangText,
              style: TextStyle(fontSize: 12, color: subTitleTextColor),
            ),
            title: Row(
              children: [
                Text(widget.indtext),
                SizedBox(
                  width: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.only(
                      top: 1.0, bottom: 2.0, left: 5.0, right: 5.0),
                  decoration: BoxDecoration(
                      color: subTitleTextColor.withOpacity(0.6),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0))),
                  child: Center(
                    child: Text(
                      widget.indCode,
                      style: TextStyle(
                        fontFamily: 'inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: titleTextColorDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            value: 1,
            groupValue: _selectedValue,
            onChanged: (int? value) {
              setState(() {
                _selectedValue = value!;
              });
              // widget.indFunc();
              ////print(_selectedValue);
              // Navigator.pop(context);
            },
          ),
          RadioListTile(
            activeColor: Provider.of<NavigationProvider>(context).themeMode ==
                    ThemeMode.light
                ? appPrimeColor
                : primaryGreenColor,
            subtitle: Text(
              widget.hniRangText,
              style: TextStyle(fontSize: 12, color: subTitleTextColor),
            ),
            title: Row(
              children: [
                Text(
                  widget.hnitext,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.only(
                      top: 1.0, bottom: 2.0, left: 5.0, right: 5.0),
                  decoration: BoxDecoration(
                      color: subTitleTextColor.withOpacity(0.6),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0))),
                  child: Center(
                    child: Text(
                      widget.hniCode,
                      style: TextStyle(
                        fontFamily: 'inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: titleTextColorDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            value: 2,
            groupValue: _selectedValue,
            onChanged: (int? value) {
              setState(() {
                _selectedValue = value!;
              });
              // widget.hniFunc();
              ////print(_selectedValue);
              // Navigator.pop(context);
            },
          ),
          Center(
            child: MaterialButton(
                padding: EdgeInsets.zero,
                minWidth: MediaQuery.of(context).size.width * 0.70,
                height: 40,
                color: appPrimeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () {
                  // //print(widget.selectedvalue);
                  // widget.selectedvalue == 1
                  //     ? widget.indFunc()
                  //     : widget.hniFunc();
                  // setState(() {});
                  _selectedValue == widget.selectedvalue
                      ? Navigator.pop(context)
                      : _selectedValue == 1
                          ? widget.indFunc()
                          : _selectedValue == 2
                              ? widget.hniFunc()
                              : print('Else');
                  // //print(_selectedValue);
                  // Navigator.pop(context);
                },
                child: Text(
                  'Continue',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'inter',
                      fontWeight: FontWeight.w900),
                )),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     Expanded(
          //       child: Padding(
          //         padding: const EdgeInsets.only(left: 20.0, right: 10.0),
          //         child: Text(
          //           widget.cateInfoText,
          //           softWrap: true,
          //           style: TextStyle(color: primaryRedColor),
          //         ),
          //       ),
          //     ),
          //     MaterialButton(
          //         padding: EdgeInsets.zero,
          //         color: appPrimeColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(18),
          //         ),
          //         onPressed: () {
          //           //print(widget.selectedvalue);
          //           // widget.selectedvalue == 1
          //           //     ? widget.indFunc()
          //           //     : widget.hniFunc();
          //           // setState(() {});
          //           Navigator.pop(context);
          //         },
          //         child: Text(
          //           'Continue',
          //           style: TextStyle(color: Colors.white),
          //         )),
          //     SizedBox(
          //       width: 20.0,
          //     )
          //   ],
          // )
        ],
      ),
    );
  }
}
