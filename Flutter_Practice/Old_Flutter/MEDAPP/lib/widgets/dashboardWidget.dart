import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medapp/customwidget.dart';
import 'package:medapp/graph.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  final String role;
  final String username;
  const Dashboard({super.key, required this.role, required this.username});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List? billMaster;
  List? stock;
  List amount = [];
  double? totalvalue;
  double yesterdaysale = 0.0;
  double totalbill = 0;

  fetchData() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    String data = sref.getString('stock') ?? '[]';
    String data1 = sref.getString('billMaster') ?? '[]';
    stock = jsonDecode(data);
    billMaster = jsonDecode(data1);
    List dummy = [
      {
        "Bill No ": "3214",
        "Bill Date ": "2023-02-11",
        "Bill Amount ": "500",
        "Bill Gst ": " 46.8",
        "Net Price ": "306.80",
        "User Id ": "ramesh"
      },
      {
        "Bill No ": "2347",
        "Bill Date ": "2023-07-27",
        "Bill Amount ": "1000",
        "Bill Gst ": " 46.8",
        "Net Price ": "306.80",
        "User Id ": "ramesh"
      },
      {
        "Bill No ": "1234",
        "Bill Date ": "2023-10-27",
        "Bill Amount ": "300",
        "Bill Gst ": " 46.8",
        "Net Price ": "306.80",
        "User Id ": "ramesh"
      },
      {
        "Bill No ": "1234",
        "Bill Date ": "2023-10-30",
        "Bill Amount ": "500",
        "Bill Gst ": " 46.8",
        "Net Price ": "306.80",
        "User Id ": "ramesh"
      }
    ];
    billMaster!.addAll(dummy);
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    DateTime previousDate = currentDate.subtract(const Duration(days: 1));
    String formatPrevDate = DateFormat('yyyy-MM-dd').format(previousDate);
    for (var bill in billMaster!) {
      if (bill['Bill Date '] == formattedDate) {
        if (widget.role == 'Biller') {
          if (bill['User Id '] == widget.username) {
            amount.add(bill['Bill Amount ']);
          }
        } else if (widget.role == 'Manager') {
          amount.add(bill['Bill Amount ']);
        }
      } else if (bill['Bill Date '] == formatPrevDate) {
        if (widget.role == 'Biller') {
          if (bill['User Id '] == widget.username) {
            yesterdaysale += double.parse(bill['Bill Amount ']);
          }
        } else if (widget.role == 'Manager') {
          yesterdaysale += double.parse(bill['Bill Amount ']);
        }
      }
    }
    if (amount.length == 1) {
      totalbill = double.parse((amount[0]));
    } else if (amount.length > 1) {
      for (var i = 0; i < amount.length; i++) {
        totalbill += double.parse(amount[i]);
      }
    }
    totalvalue = getTotalStockValue(stock!);

    setState(() {});
  }

  double percentagecalculation() {
    if (yesterdaysale == 0) {
      return 0;
    } else {
      if (totalbill == 0) {
        return 0;
      } else {
        return ((totalbill - yesterdaysale) / yesterdaysale) * 100;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (billMaster == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      String percentageText;
      Icon? arrowIcon;

      double percentageChange = percentagecalculation();
      if (percentageChange > 0) {
        percentageText = '${percentageChange.toStringAsFixed(2)}%';
        arrowIcon = const Icon(
          Icons.arrow_upward,
          color: Colors.green,
        );
      } else if (percentageChange < 0) {
        percentageText = '${percentageChange.toStringAsFixed(2)}%';
        arrowIcon = const Icon(
          Icons.arrow_downward,
          color: Colors.red,
        );
      } else {
        percentageText = '';
        arrowIcon = null;
      }
      return SafeArea(
        child: widget.role == 'Biller'
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Card(
                    elevation: 10.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Today Sales',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              billMaster!.isEmpty ? 'Rs. 0' : 'Rs. $totalbill',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (arrowIcon != null) ...[
                              Text(
                                percentageText,
                                style: TextStyle(
                                  color: percentageChange > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16.0,
                                ),
                              ),
                              arrowIcon,
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : widget.role == 'Manager'
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Card(
                            elevation: 10.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  'Today Sales',
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      billMaster!.isEmpty
                                          ? 'Rs. 0'
                                          : 'Rs. $totalbill',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (arrowIcon != null) ...[
                                      Text(
                                        percentageText,
                                        style: TextStyle(
                                          color: percentageChange > 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      arrowIcon,
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Card(
                            elevation: 10.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  'Current Inventory Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rs. ${totalvalue.toString()}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: SizedBox(
                                  height: 400,
                                  width: 800,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Monthly Sales Trend'),
                                          const Expanded(child: Text('')),
                                          InkWell(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: const Icon(
                                                  Icons.close_rounded)),
                                        ],
                                      ),
                                      buildMonthlySalesChart(billMaster!),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const ListTile(
                          title: Text('Monthly Sales Trend'),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: SizedBox(
                                  height: 400,
                                  width: 800,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Daily Sales Trend'),
                                          const Expanded(child: Text('')),
                                          InkWell(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: const Icon(
                                                  Icons.close_rounded)),
                                        ],
                                      ),
                                      buildDailySalesChart(billMaster!),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const ListTile(
                          title: Text('Daily Sales Trend'),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: SizedBox(
                                  height: 400,
                                  width: 1000,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                              'Today Biller Performance'),
                                          const Expanded(child: Text('')),
                                          InkWell(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: const Icon(
                                                  Icons.close_rounded)),
                                        ],
                                      ),
                                      buildBillerPerformancePieChart(
                                          billMaster!)
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const ListTile(
                          title: Text('Today Biller Performance'),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: SizedBox(
                                  height: 400,
                                  width: 500,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Current Month Biller Performance',
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          const Expanded(child: Text('')),
                                          InkWell(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: const Icon(
                                                  Icons.close_rounded)),
                                        ],
                                      ),
                                      buildBillerPerformanceBarChart(
                                          billMaster!),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const ListTile(
                          title: Text('Current Month Biller Performance'),
                        ),
                      ),
                    ],
                  )
                : widget.role == 'Inventory'
                    ? dashboard3()
                    : dashboard3(),
      );
    }
  }
}
