import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medapp/customwidget.dart';
import 'package:medapp/userdetails.dart';
import 'package:medapp/widgets/snackBar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class BillEntry extends StatefulWidget {
  final String userId;
  const BillEntry({super.key, required this.userId});

  @override
  State<BillEntry> createState() => _BillEntryState();
}

class _BillEntryState extends State<BillEntry> {
  @override
  void initState() {
    super.initState();
    fetchData();
    billno = billEntry();
  }

  SharedPreferences? sref;
  String? billno;
  List? bills;
  List? stock;
  List billMaster = [];
  List billDetails = [];
  List? medicineMaster;
  TextEditingController qtyController = TextEditingController();
  final qtyKey = GlobalKey<FormState>();
  String? selectedOption;

  String searchValue = '';

  List selecteditem = [];

  TextEditingController searchController = TextEditingController();

  fetchData() async {
    sref = await SharedPreferences.getInstance();
    String data = sref!.getString('billMaster') ?? '[]';
    String data1 = sref!.getString('billDetails') ?? '[]';
    String data2 = sref!.getString('stock') ?? '[]';
    String data3 = sref!.getString('medicineMaster') ?? '[]';
    billMaster = jsonDecode(data);
    bills = billformat;
    billDetails = jsonDecode(data1);
    stock = jsonDecode(data2);
    medicineMaster = jsonDecode(data3);

    setState(() {});
  }

  billEntry() {
    final random = Random();
    int min = 1000;
    int max = 9999;
    int billno = min + random.nextInt(max - min + 1);
    return billno.toString();
  }

  updatebillNo() {
    setState(() {
      billno = billEntry();
      bills![0]['Bill No '] = billno;
    });
  }

  double totalAmount = 0.0;
  void updateValues() {
    double totalAmount = total(selecteditem);
    setState(() {
      double gst = totalAmount * 18 / 100;
      BillItemDetails newdetails = BillItemDetails(
          date(), selecteditem.last.amount, gst, widget.userId, billno!);
      Map details = {
        'Bill No ': newdetails.billno,
        'Bill Date ': newdetails.billdate,
        'Bill Amount ': newdetails.amount.toString(),
        'Bill Gst ': newdetails.gst.toString(),
        'Net Price ': newdetails.price.toStringAsFixed(2),
        'User Id ': newdetails.id
      };
      billMaster.add(details);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (stock == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      List<String> keys = bills![0].keys.toList();
      List options = stock!.map((e) => e['Medicine Name']).toList();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                  child: Text(''),
                ),
                Column(
                  children: [
                    ExpansionTile(
                      title: const Text('Bill Entry'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Form(
                            key: qtyKey,
                            child: Column(
                              children: [
                                DropdownButton<String>(
                                  hint: const Text('Medicine Name'),
                                  items: options
                                      .map<DropdownMenuItem<String>>((item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    );
                                  }).toList(),
                                  value: selectedOption,
                                  onChanged: (newValue) {
                                    setState(
                                      () {
                                        selectedOption = newValue;
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                myform(
                                  icon: Icons.shopping_cart,
                                  text: 'Quantity',
                                  ctrl: qtyController,
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (qtyKey.currentState!.validate()) {
                                      int totalqty = int.parse(stock!
                                              .firstWhere((element) =>
                                                  element['Medicine Name'] ==
                                                  selectedOption)['quantity']) -
                                          int.parse(qtyController.text);

                                      if (totalqty >= 0) {
                                        stock!.firstWhere((element) =>
                                                element['Medicine Name'] ==
                                                selectedOption)['quantity'] =
                                            totalqty.toString();

                                        if ((int.parse(qtyController.text)) >
                                            0) {
                                          selecteditem.add(
                                            BillItem(
                                              selectedOption!,
                                              medicineMaster!.firstWhere(
                                                  (element) =>
                                                      element[
                                                          'Medicine Name'] ==
                                                      selectedOption)['Brand'],
                                              int.parse(qtyController.text),
                                              double.parse(stock!.firstWhere(
                                                      (element) =>
                                                          element[
                                                              'Medicine Name'] ==
                                                          selectedOption)[
                                                  'Unit Price']),
                                            ),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const MySnackBar(
                                                    message:
                                                        'Stock Added ...!!!',
                                                    color: Colors.green)
                                                .openSnackBar(),
                                          );
                                          BillItem newItem = BillItem(
                                            selectedOption!,
                                            medicineMaster!.firstWhere(
                                                (element) =>
                                                    element['Medicine Name'] ==
                                                    selectedOption)['Brand'],
                                            int.parse(qtyController.text),
                                            double.parse(stock!.firstWhere(
                                                    (element) =>
                                                        element[
                                                            'Medicine Name'] ==
                                                        selectedOption)[
                                                'Unit Price']),
                                          );
                                          Map billItemMap = {
                                            'Bill No ': billno,
                                            'Medicine Name ': newItem.name,
                                            'Quantity ': newItem.quantity,
                                            'Unit Price ': newItem.unitPrice,
                                            'Amount ': newItem.amount
                                          };
                                          billDetails.add(billItemMap);
                                          qtyController.clear();
                                          updateValues();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const MySnackBar(
                                                    message:
                                                        'Quantity must be greater than 0 ',
                                                    color: Colors.red)
                                                .openSnackBar(),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const MySnackBar(
                                                  message: 'Insufficient Stock',
                                                  color: Colors.red)
                                              .openSnackBar(),
                                        );
                                      }

                                      setState(() {
                                        searchValue = selectedOption!;
                                      });
                                    }
                                  },
                                  child: const Text("Add"),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Colors.red,
                            ),
                          ),
                          onPressed: () {
                            double totalAmount = total(selecteditem);
                            double gst = totalAmount * 18 / 100;
                            double netPrice = totalAmount + gst;

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: SizedBox(
                                    height: 300,
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        AppBar(
                                          leading: InkWell(
                                              splashColor: Colors.transparent,
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: const Icon(
                                                  Icons.close_rounded)),
                                          title: const Text('Bill Preview'),
                                          centerTitle: true,
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              columnSpacing: 25.0,
                                              columns: const [
                                                DataColumn(
                                                  label: Expanded(
                                                    child: Text(
                                                      'M.Name',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Expanded(
                                                    child: Text(
                                                      'Quantity',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Expanded(
                                                    child: Text(
                                                      'Amount',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              rows: selecteditem.map(
                                                (item) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Text(item.name),
                                                      ),
                                                      DataCell(
                                                        Text(item.quantity
                                                            .toString()),
                                                      ),
                                                      DataCell(
                                                        Text((item.quantity *
                                                                item.unitPrice)
                                                            .toString()),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ).toList(),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Total : ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                                totalAmount.toStringAsFixed(2)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'GST : ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(gst.toStringAsFixed(2)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Net Price : ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(netPrice.toStringAsFixed(2)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text("Preview"),
                        ),
                        ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Colors.green,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              sref!.setString(
                                'stock',
                                jsonEncode(stock),
                              );
                              sref!.setString(
                                  'billMaster', jsonEncode(billMaster));
                              sref!.setString(
                                  'billDetails', jsonEncode(billDetails));
                              selecteditem.clear();
                              updatebillNo();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const MySnackBar(
                                        message: 'Save Sucessfully ...!!!',
                                        color: Colors.green)
                                    .openSnackBar(),
                              );
                            });
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      height: 100.0,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1.0,
                        childAspectRatio: 7.8,
                        children: List.generate(
                          keys.length - 1,
                          (index) {
                            totalAmount = total(selecteditem);
                            double gst = totalAmount * 18 / 100;
                            BillItemDetails nitem = BillItemDetails(date(),
                                totalAmount, gst, widget.userId, billno!);
                            String key = keys[index];

                            return Row(
                              children: [
                                Text('$key :'),
                                Text(key == 'Bill No '
                                    ? billno!
                                    : key == 'Bill Date '
                                        ? nitem.billdate
                                        : key == 'Bill Amount '
                                            ? nitem.amount.toString()
                                            : key == 'Bill Gst '
                                                ? nitem.gst.toString()
                                                : key == 'Net Price '
                                                    ? nitem.price
                                                        .toStringAsFixed(2)
                                                    : nitem.id),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 25.0,
                        columns: const [
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Med Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Brand',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Quantity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Amount',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: selecteditem.map(
                          (item) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(item.name),
                                ),
                                DataCell(
                                  Text(item.brand),
                                ),
                                DataCell(
                                  Text(item.quantity.toString()),
                                ),
                                DataCell(
                                  Text(item.amount.toString()),
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
