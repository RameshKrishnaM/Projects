import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({Key? key}) : super(key: key);

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  TextEditingController searchController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  List? billMaster;
  List? billDetails;
  List filteredSalesData = [];
  String searchValue = '';
  List? searchData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    String data = sref.getString('billMaster') ?? '[]';
    String data1 = sref.getString('billDetails') ?? '[]';
    billMaster = jsonDecode(data);
    billDetails = jsonDecode(data1);
    setState(() {
      for (int i = 0; i < billMaster!.length; i++) {
        String billDate = billMaster![i]['Bill Date '];

        Map<String, dynamic> salesRecord = {
          'Bill No ': billMaster![i]['Bill No '],
          'Bill Date ': billDate,
          'Medicine Name ': billDetails![i]['Medicine Name '],
          'Quantity ': billDetails![i]['Quantity '],
          'Amount ': billDetails![i]['Amount '],
        };
        filteredSalesData.add(salesRecord);
        searchData = filteredSalesData;
      }
    });
  }

  Future<void> selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != controller.text) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      controller.text = formattedDate;
    }
  }

  void filterSalesData() {
    filteredSalesData = [];

    if (billMaster == null || billDetails == null) {
      return;
    }

    String fromDate = fromController.text;
    String toDate = toController.text;

    for (int i = 0; i < billMaster!.length; i++) {
      String billDate = billMaster![i]['Bill Date '];
      if (billDate.compareTo(fromDate) >= 0 &&
          billDate.compareTo(toDate) <= 0) {
        Map<String, dynamic> salesRecord = {
          'Bill No ': billMaster![i]['Bill No '],
          'Bill Date ': billDate,
          'Medicine Name ': billDetails![i]['Medicine Name '],
          'Quantity ': billDetails![i]['Quantity '],
          'Amount ': billDetails![i]['Amount '],
        };
        filteredSalesData.add(salesRecord);
      }
    }
  }

  List<Map<String, dynamic>> filterBillsBySearch(String searchValue) {
    List<Map<String, dynamic>> result = [];

    for (int i = 0; i < searchData!.length; i++) {
      final billNo = searchData![i]['Bill No '] ?? '';
      final billDate = searchData![i]['Bill Date '] ?? '';
      final medicineName = searchData![i]['Medicine Name '] ?? '';
      final quantity = searchData![i]['Quantity '] ?? '';
      final amount = searchData![i]['Amount '] ?? '';

      final concatenatedValues =
          '$billNo $billDate $medicineName $quantity $amount';

      if (concatenatedValues
          .toLowerCase()
          .contains(searchValue.toLowerCase())) {
        Map<String, dynamic> record = {
          'Bill No ': billNo,
          'Bill Date ': billDate,
          'Medicine Name ': medicineName,
          'Quantity ': quantity,
          'Amount ': amount,
        };
        result.add(record);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            ExpansionTile(
              title: const Text('Search'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: fromController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              selectDate(context, fromController);
                            },
                            child: const Icon(
                              Icons.calendar_month_rounded,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          labelText: 'Enter From Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: toController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                selectDate(context, toController);
                              },
                              child: const Icon(
                                Icons.calendar_month_rounded,
                              )),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          labelText: 'Enter to Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          filterSalesData();
                          setState(() {});
                        },
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchValue = searchController.text;
                  filteredSalesData = filterBillsBySearch(searchValue);
                });
              },
              controller: searchController,
              decoration: const InputDecoration(
                suffixIcon: InkWell(
                  splashColor: Colors.transparent,
                  child: Icon(Icons.search),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 13.0,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Bill No',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Bill Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Med Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: filteredSalesData.isEmpty
                    ? [
                        const DataRow(
                          cells: [
                            DataCell(
                              Text(''),
                            ),
                            DataCell(
                              Text(''),
                            ),
                            DataCell(
                              Text('No Data Found'),
                            ),
                            DataCell(
                              Text(''),
                            ),
                            DataCell(
                              Text(''),
                            ),
                          ],
                        ),
                      ]
                    : filteredSalesData.map((salesRecord) {
                        return DataRow(
                          cells: [
                            DataCell(Text(salesRecord['Bill No '] ??
                                'N/A')), // Use 'N/A' as a default value
                            DataCell(Text(salesRecord['Bill Date '] ?? 'N/A')),
                            DataCell(
                                Text(salesRecord['Medicine Name '] ?? 'N/A')),
                            DataCell(Text(
                                salesRecord['Quantity ']?.toString() ??
                                    'N/A')), // Handle null with a default value
                            DataCell(Text(
                                salesRecord['Amount ']?.toString() ?? 'N/A'))
                          ],
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
