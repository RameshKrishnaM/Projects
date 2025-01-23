import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ekycold/esign.dart';
import 'package:ekycold/util/colors.dart';
import 'package:ekycold/widgets/fab.dart';
import 'package:ekycold/widgets/mybottomsheet.dart';
import 'package:ekycold/widgets/panwidget.dart';
import 'package:flutter/material.dart';

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
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isExpanded) {
          isExpanded = false;
          setState(() {});
          return false;
        }
        return true;
      },
      child: Scaffold(
        // backgroundColor: const Color.fromRGBO(228, 242, 253, 1.0),
        floatingActionButton: MyFAB(
          mini: true,
          icon: isExpanded
              ? Icons.keyboard_double_arrow_down_sharp
              : Icons.keyboard_double_arrow_up_sharp,
          onPressed: () {
            isExpanded = false;
            setState(() {});
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(15.0),
            children: [
              Text(
                'Demant',
                style: Theme.of(context).textTheme.bodyLarge,
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
                        border: Border.all(
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    hint: const Text('Select Option'),
                    items: options.map<DropdownMenuItem<String>>((item) {
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
                  ),
                  Radio(
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
                'assets/images/demat-account.png',
              ),
              const SizedBox(
                height: 10.0,
              ),
              PanWidget(
                onPressed: () {
                  isExpanded = !isExpanded;
                  setState(() {});
                },
              )
            ],
          ),
        ),
        bottomSheet: MyBottomSheet(
          isExpanded: isExpanded,
          onPressed: () {
            isExpanded = false;
            // Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Esign(),
              ),
            );
            // Navigator.pushNamed(context, route.fileUpload);
            setState(() {});
          },
        ),
      ),
    );
  }
}
