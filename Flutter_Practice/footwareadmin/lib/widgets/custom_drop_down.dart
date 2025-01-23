// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';

// class CustomDropDown extends StatelessWidget {
//   final TextEditingController controller;
//   final List values;
//   final bool isIcon;
//   final String? label;
//   final bool buttonSizeIsSmall;
//   final double menuHeight;
//   final onChange;
//   final String? hint;
//   const CustomDropDown(
//       {super.key,
//       required this.controller,
//       this.label,
//       required this.values,
//       this.buttonSizeIsSmall = false,
//       this.isIcon = false,
//       this.onChange,
//       this.menuHeight = 150,
//       this.hint});

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton2(
//       underline: const Text(''),
//       buttonStyleData: ButtonStyleData(
//         height: 30.0,
//         padding: EdgeInsets.zero,
//         decoration: BoxDecoration(
//           border: Border.all(
//             width: 1.0,
//           ),
//           borderRadius: BorderRadius.circular(20.0),
//         ),
//       ),
//       menuItemStyleData: const MenuItemStyleData(
//         height: 35.0,
//       ),
//       dropdownStyleData: DropdownStyleData(
//         maxHeight: 150.0,
//         decoration: BoxDecoration(
//           border: Border.all(
//             width: 1.0,
//           ),
//           borderRadius: BorderRadius.circular(20.0),
//         ),
//       ),
//       hint: const Text('Select Option'),
//       items: values.map<DropdownMenuItem<String>>((item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Scrollbar(
//             child: Text(item),
//           ),
//         );
//       }).toList(),
//       value: selectedItem,
//       onChanged: (value) {
//         selectedItem = value;
//       },
//     );
//   }
// }
