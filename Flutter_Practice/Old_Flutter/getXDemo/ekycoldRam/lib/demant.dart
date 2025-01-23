import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:projectdemo2/widgets/fab.dart';
import 'package:projectdemo2/widgets/mybottomsheet.dart';
import 'package:projectdemo2/widgets/mycolor.dart';
import 'package:projectdemo2/widgets/panwidget.dart';
import 'package:projectdemo2/widgets/providerclss.dart';
import 'package:provider/provider.dart';

class DemantScreen extends StatefulWidget {
  const DemantScreen({Key? key}) : super(key: key);

  @override
  State<DemantScreen> createState() => _DemantScreenState();
}

class _DemantScreenState extends State<DemantScreen> {
  String? selectedItem;
  String? selectedValue1;
  String? selectedValue2;
  bool isStretched = false;
  // openbottomsheet(isExpanded) {
  //   return MyBottomSheet(
  //     isExpanded: isExpanded,
  //     onPressed: () {},
  //   );
  // }

  List<String> options = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
    'Option 5',
    'Option 6',
    'Option 7',
    'Option 8',
    'Option 9',
    'Option 10'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return WillPopScope(
          onWillPop: () async {
            if (value.isExpanded) {
              value.isExpanded = false;
              setState(() {});
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color.fromRGBO(228, 242, 253, 1.0),
            floatingActionButton: const MyFAB(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgcolor1,
                      bgcolor3,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(15.0),
                  children: [
                    const Text(
                      'Demant',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton2(
                          underline: const Text(''),
                          buttonStyleData: ButtonStyleData(
                            height: 30.0,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: dropdownbordercolor,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 35.0,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 150.0,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: ipvcodecolor),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          hint: const Text('Select Option'),
                          items: [
                            'Default',
                            'value1',
                            'value2',
                            'Value3',
                            'Value4',
                          ].map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Scrollbar(
                                child: Text(item),
                              ),
                            );
                          }).toList(),
                          value: selectedItem,
                          onChanged: (value) {
                            setState(() {
                              selectedItem = value;
                            });
                          },
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'View Scheme Details',
                            style: TextStyle(
                              color: highlightcolor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'Do you Require DIS Slip Book ?',
                    ),
                    Row(
                      children: [
                        Radio(
                          activeColor: highlightcolor,
                          value: 'Yes',
                          groupValue: selectedValue1,
                          onChanged: (value) {
                            setState(
                              () {
                                selectedValue1 = value;
                              },
                            );
                          },
                        ),
                        const Text(
                          'Yes',
                          style: TextStyle(),
                        ),
                        Radio(
                          activeColor: highlightcolor,
                          value: 'No',
                          groupValue: selectedValue1,
                          onChanged: (value) {
                            setState(
                              () {
                                selectedValue1 = value;
                              },
                            );
                          },
                        ),
                        const Text(
                          'No',
                          style: TextStyle(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'Whether you are required to transact EDIS transaction for sale obligation ?',
                    ),
                    Row(
                      children: [
                        Radio(
                          activeColor: highlightcolor,
                          value: 'option1',
                          groupValue: selectedValue2,
                          onChanged: (value) {
                            setState(
                              () {
                                selectedValue2 = value;
                              },
                            );
                          },
                        ),
                        const Text(
                          'Yes',
                        ),
                        Radio(
                          activeColor: highlightcolor,
                          value: 'option2',
                          groupValue: selectedValue2,
                          onChanged: (value) {
                            setState(
                              () {
                                selectedValue2 = value;
                              },
                            );
                          },
                        ),
                        const Text(
                          'No',
                        ),
                      ],
                    ),
                    Image.asset(
                      'images/demat-account1-removebg-preview.png',
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    PanWidget(
                      onPressed: () {
                        value.changeExpanded();
                      },
                    )
                  ],
                ),
              ),
            ),
            bottomSheet: MyBottomSheet(
              isExpanded: value.isExpanded,
              onPressed: () {
                value.isExpanded = false;
                Navigator.pop(context);
                // Navigator.pushNamed(context, route.fileUpload);
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}
