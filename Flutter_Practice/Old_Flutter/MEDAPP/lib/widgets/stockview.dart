import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockView extends StatefulWidget {
  const StockView({super.key});

  @override
  State<StockView> createState() => _StockViewState();
}

class _StockViewState extends State<StockView> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List? medicineMaster;
  List? stock;
  int rowsPerPage = -1;
  int currentPage = 1;
  fetchData() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    String data = sref.getString('medicineMaster') ?? '[]';
    String data1 = sref.getString('stock') ?? '[]';
    medicineMaster = jsonDecode(data);
    stock = jsonDecode(data1);
    sref.setString('medicineMaster', jsonEncode(medicineMaster));
    sref.setString('stock', jsonEncode(stock));

    setState(() {});
  }

  String searchValue = '';
  TextEditingController searchController = TextEditingController();
  List getFilteredStockList(String searchValue) {
    if (stock != null && stock!.isNotEmpty) {
      return stock!.where((item) {
        final concatenatedValues =
            '${item['Medicine Name']} ${getBrandForMedicine(item['Medicine Name'])} ${item['quantity']} ${item['Unit Price']}';
        return concatenatedValues
            .toLowerCase()
            .contains(searchValue.toLowerCase());
      }).toList();
    } else {
      return [];
    }
  }

  String getBrandForMedicine(String medicineName) {
    final brand = medicineMaster!.firstWhere(
        (element) => element['Medicine Name'] == medicineName)['Brand'];

    return brand;
  }

  @override
  Widget build(BuildContext context) {
    final filteredStockList = getFilteredStockList(searchValue);
    final totalPages = (filteredStockList.length / rowsPerPage).ceil();

    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex =
        (currentPage * rowsPerPage).clamp(0, filteredStockList.length);

    final pageItems = rowsPerPage == -1
        ? filteredStockList
        : filteredStockList.sublist(startIndex, endIndex);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchValue = searchController.text;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rows Per Page : '),
                  DropdownButton<int>(
                    value: rowsPerPage,
                    items: [5, 10, 15, 20, -1].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: value == -1
                            ? const Text('All')
                            : Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        rowsPerPage = newValue!;
                        currentPage = 1;
                      });
                    },
                  ),
                ],
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
                          'Unit Price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: pageItems.map(
                    (item) {
                      Map brandInfo = medicineMaster!.firstWhere((element) =>
                          element['Medicine Name'] == item['Medicine Name']);
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(item['Medicine Name']),
                          ),
                          DataCell(
                            Text(brandInfo['Brand']),
                          ),
                          DataCell(
                            Text(item['quantity']),
                          ),
                          DataCell(
                            Text(item['Unit Price']),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (currentPage > 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentPage--;
                        });
                      },
                      child: const Text('Previous Page'),
                    ),
                  if (currentPage < totalPages)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentPage++;
                        });
                      },
                      child: const Text('Next Page'),
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
