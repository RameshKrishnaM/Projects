import 'package:flutter/material.dart';

dashboard3() {
  return const Padding(
    padding: EdgeInsets.all(10.0),
    child: SizedBox(
      height: 200,
      width: double.infinity,
      child: Card(
        elevation: 10.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'WELCOME !',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

myform({
  required String text,
  required TextEditingController ctrl,
  bool? enable,
  required IconData icon,
}) {
  return TextFormField(
    enabled: enable,
    controller: ctrl,
    decoration: InputDecoration(
      suffixIcon: Icon(icon),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      labelText: text,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    validator: (value) {
      if (value!.isEmpty) {
        return 'Container is Empty';
      }
      return null;
    },
  );
}

date() {
  DateTime now = DateTime.now();
  String formatedDate =
      "${now.year}-${twoDigits(now.month)}-${twoDigits(now.day)}";
  return formatedDate;
}

String twoDigits(int n) {
  if (n >= 10) {
    return "$n";
  } else {
    return "0$n";
  }
}

total(List items) {
  double total = 0;
  for (var item in items) {
    total += item.amount;
  }
  return total;
}

dateTime() {
  DateTime now = DateTime.now();

  String formatedDate =
      '${now.year} - ${twoDigits(now.month)} - ${twoDigits(now.day)} / ${now.hour} : ${now.minute} : ${now.second}';
  return formatedDate;
}

double getTotalStockValue(List stockList) {
  double totalValue = 0.0;
  if (stockList.isNotEmpty) {
    for (var item in stockList) {
      double quantity = double.tryParse(item['quantity']) ?? 0.0;
      double unitPrice = double.tryParse(item['Unit Price']) ?? 0.0;
      totalValue += quantity * unitPrice;
    }
  }
  return totalValue;
}



/*

  List getFilteredStockList(String searchValue) {
    if (stock != null && stock!.isNotEmpty) {
      return stock!
          .where((item) => item['Medicine Name']
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
          .toList();
    } else {
      return [];
    }
  }
  
 */