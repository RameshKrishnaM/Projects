import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medapp/customwidget.dart';
import 'package:medapp/widgets/snackBar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class StockEntry extends StatefulWidget {
  const StockEntry({super.key});

  @override
  State<StockEntry> createState() => _StockEntryState();
}

class _StockEntryState extends State<StockEntry> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  bool isDropDown = true;
  TextEditingController brndController = TextEditingController();
  TextEditingController medController = TextEditingController();
  final medKey = GlobalKey<FormState>();
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final updateKey = GlobalKey<FormState>();
  String? selectedOption;
  SharedPreferences? sref;
  List? medicineMaster;
  List? stock;

  fetchData() async {
    sref = await SharedPreferences.getInstance();
    String data = sref!.getString('medicineMaster') ?? '[]';
    String data1 = sref!.getString('stock') ?? '[]';
    medicineMaster = jsonDecode(data);
    stock = jsonDecode(data1);

    setState(() {});
  }

  void addStockEntry(String medName, String brand) {
    bool isMedicineExist =
        medicineMaster!.any((item) => item['Medicine Name'] == medName);

    if (!isMedicineExist) {
      Map dummy = {'Medicine Name': medName, 'Brand': brand};
      medicineMaster!.add(dummy);
      ScaffoldMessenger.of(context).showSnackBar(
        const MySnackBar(message: 'Added Sucessfully', color: Colors.green)
            .openSnackBar(),
      );
      updateDropdownOptions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const MySnackBar(message: 'Alredy Exist ...!!!', color: Colors.red)
            .openSnackBar(),
      );
    }
    setState(() {
      sref!.setString('medicineMaster', jsonEncode(medicineMaster));
    });
  }

  void updateStockEntry(String medName, String quantity, String netPrice) {
    bool isStockUpdated = false;
    for (var item in stock!) {
      if (item['Medicine Name'] == medName) {
        int totalqty = int.parse(item['quantity']) + int.parse(quantity);
        item['quantity'] = totalqty.toString();
        item['Unit Price'] = netPrice;
        isStockUpdated = true;
        break;
      }
    }
    if (!isStockUpdated) {
      Map newItem = {
        'Medicine Name': medName,
        'quantity': quantity,
        'Unit Price': netPrice,
      };
      stock!.add(newItem);
    }
    setState(() {});
    updateDropdownOptions();
  }

  List options = [];
  void updateDropdownOptions() {
    options = medicineMaster!.map((e) => e['Medicine Name']).toList();
  }

  String? findBrandName(String selectedMedicine) {
    for (var item in medicineMaster!) {
      if (item['Medicine Name'] == selectedMedicine) {
        return item['Brand'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (stock == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      options = medicineMaster!.map((e) => e['Medicine Name']).toList();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Refill Stock',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            height: 10.0,
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  contentPadding: const EdgeInsets.all(10.0),
                                  content: SizedBox(
                                    height: 300.0,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          child: ListTile(
                                            leading: IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(Icons.close),
                                            ),
                                            title: const Text('Add Stock'),
                                          ),
                                        ),
                                        Form(
                                          key: medKey,
                                          child: Column(
                                            children: [
                                              myform(
                                                icon: Icons
                                                    .medical_information_rounded,
                                                text: 'Enter Medicine Name',
                                                ctrl: medController,
                                              ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              myform(
                                                icon: Icons
                                                    .branding_watermark_rounded,
                                                text: 'Enter Brand',
                                                ctrl: brndController,
                                              ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (medKey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      addStockEntry(
                                                          medController.text,
                                                          brndController.text);
                                                      medController.clear();
                                                      brndController.clear();
                                                      sref!.setString(
                                                          'medicineMaster',
                                                          jsonEncode(
                                                              medicineMaster));
                                                    });
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: const Text("Add"),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      '+ Add',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 500.0,
                width: double.infinity,
                child: Card(
                  child: Form(
                    key: updateKey,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          DropdownButton(
                            hint: const Text('Medicine Name'),
                            items:
                                options.map<DropdownMenuItem<String>>((item) {
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
                                  isDropDown = false;
                                  if (selectedOption != null &&
                                      selectedOption!.isNotEmpty) {
                                    String? brandName =
                                        findBrandName(selectedOption!);
                                    if (brandName != null) {
                                      brndController.text = brandName;
                                    }
                                  }
                                },
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          myform(
                            icon: Icons.branding_watermark_rounded,
                            text: 'Brand',
                            ctrl: brndController,
                            enable: isDropDown,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          myform(
                              text: 'Quantity',
                              ctrl: qtyController,
                              icon: Icons.shopping_cart),
                          const SizedBox(
                            height: 10.0,
                          ),
                          myform(
                            text: 'Net Price',
                            ctrl: priceController,
                            icon: Icons.currency_rupee,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (updateKey.currentState!.validate()) {
                                updateStockEntry(selectedOption!,
                                    qtyController.text, priceController.text);
                              }
                              qtyController.clear();
                              priceController.clear();
                              setState(() {
                                sref!.setString('stock', jsonEncode(stock));
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const MySnackBar(
                                        message: 'update Sucessfully ...!!!',
                                        color: Colors.green)
                                    .openSnackBar(),
                              );
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
