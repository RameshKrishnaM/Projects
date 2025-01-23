// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PortfolioChart extends StatelessWidget {
  final List<ChartData> chartData = getChartData();
  final double totalValue;

  PortfolioChart({super.key})
      : totalValue = getChartData().fold(0, (sum, data) => sum + data.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 0, 0),
                  child: Text(
                    ' ₹${totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(4, 159, 122, 1)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(45, 0, 0, 0),
                  child: Text(
                    "Portfolio value",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: SfCartesianChart(
                    trackballBehavior: TrackballBehavior(
                        activationMode: ActivationMode.singleTap,
                        enable: true,
                        lineColor: const Color.fromRGBO(4, 159, 122, 1)),
                    plotAreaBorderWidth: 0,
                    primaryXAxis: const DateTimeAxis(
                      isVisible: false,
                      majorGridLines: MajorGridLines(width: 0),
                    ),
                    primaryYAxis: const NumericAxis(
                      isVisible: false,
                      axisLine: AxisLine(width: 0, color: Colors.white),
                      majorGridLines: MajorGridLines(width: 0),
                    ),
                    series: <CartesianSeries>[
                      SplineAreaSeries<ChartData, DateTime>(
                        splineType: SplineType.cardinal,
                        cardinalSplineTension: 0.3,
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.value,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(182, 227, 216, 0.5),
                            Colors.white
                          ],
                          stops: [0.1, 2.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderColor: const Color.fromRGBO(4, 159, 122, 1),
                        borderWidth: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Column(
                children: [
                  Text(
                    '₹25000',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Invested amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 120,
                    decoration: const BoxDecoration(
                        border:
                            Border(left: BorderSide(), right: BorderSide())),
                    child: const Text(
                      '₹111839',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Text(
                    'Returns',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const Column(
                children: [
                  Text(
                    '45.25%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'XIRR',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final int value;
  ChartData(this.date, this.value);
}

List<ChartData> getChartData() {
  final List<Map<String, dynamic>> chartData = [
    {"Date": DateTime(2024, 05, 1), "Value": 100},
    {"Date": DateTime(2024, 05, 2), "Value": 500},
    {"Date": DateTime(2024, 05, 3), "Value": 2000},
    {"Date": DateTime(2024, 05, 4), "Value": 500},
    {"Date": DateTime(2024, 05, 5), "Value": 100},
    {"Date": DateTime(2024, 05, 6), "Value": 1000},
    {"Date": DateTime(2024, 05, 7), "Value": 5000},
    {"Date": DateTime(2024, 05, 8), "Value": 4000},
    {"Date": DateTime(2024, 05, 9), "Value": 6000},
    {"Date": DateTime(2024, 05, 10), "Value": 6000},
    {"Date": DateTime(2024, 05, 11), "Value": 5000},
    {"Date": DateTime(2024, 05, 12), "Value": 7000},
    {"Date": DateTime(2024, 05, 13), "Value": 10000},
    {"Date": DateTime(2024, 05, 14), "Value": 9000},
    {"Date": DateTime(2024, 05, 15), "Value": 11000},
    {"Date": DateTime(2024, 05, 16), "Value": 10000},
    {"Date": DateTime(2024, 05, 17), "Value": 10000},
    {"Date": DateTime(2024, 05, 18), "Value": 9000},
    {"Date": DateTime(2024, 05, 19), "Value": 9500},
    {"Date": DateTime(2024, 05, 20), "Value": 10000},
    {"Date": DateTime(2024, 05, 21), "Value": 11000},
    {"Date": DateTime(2024, 05, 22), "Value": 11500},
    {"Date": DateTime(2024, 05, 23), "Value": 11000},
    {"Date": DateTime(2024, 05, 24), "Value": 12500},
  ];

  return chartData
      .map((data) => ChartData(data["Date"], data["Value"]))
      .toList();
}
