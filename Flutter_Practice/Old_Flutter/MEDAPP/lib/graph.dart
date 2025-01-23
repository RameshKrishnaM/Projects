import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

Widget buildDailySalesChart(List billMaster) {
  List<Map<String, dynamic>> last7DaysSalesData = [];
  bool isDateWithinLast7Days(DateTime dateToCheck) {
    final today = DateTime.now();
    final lastWeek = today.subtract(const Duration(days: 7));

    return dateToCheck.isAfter(lastWeek) && dateToCheck.isBefore(today);
  }

  double calculateSalesForDay(String dayName) {
    double salesAmount = 0.0;

    for (var bill in billMaster) {
      String billDate = bill['Bill Date '];
      String billAmount = bill['Bill Amount '];
      if (isDateWithinLast7Days(DateTime.parse(billDate))) {
        final day =
            DateFormat('EEEE').format(DateTime.parse(billDate)).substring(0, 3);
        if (day == dayName) {
          salesAmount += double.parse(billAmount);
        }
      }
    }

    return salesAmount;
  }

  String getDayName(int dayIndex) {
    final today = DateTime.now();
    final daysAgo = today.subtract(Duration(days: dayIndex));
    return DateFormat('EEE').format(daysAgo);
  }

  for (int i = 6; i >= 0; i--) {
    final dayName = getDayName(i);
    final salesAmount = calculateSalesForDay(dayName);
    last7DaysSalesData.add({'day': dayName, 'sales': salesAmount});
  }

  return SfCartesianChart(
    tooltipBehavior: TooltipBehavior(
      enable: true,
    ),
    legend: const Legend(
      isVisible: true,
    ),
    primaryXAxis: CategoryAxis(),
    series: <CartesianSeries<Map<String, dynamic>, String>>[
      LineSeries<Map<String, dynamic>, String>(
        animationDuration: 0,
        dataSource: last7DaysSalesData,
        xValueMapper: (data, _) => data['day'],
        yValueMapper: (data, _) => data['sales'],
        dataLabelSettings: const DataLabelSettings(isVisible: true),
        name: 'Last 7 Days Sales',
      ),
    ],
  );
}

Widget buildMonthlySalesChart(List billMaster) {
  List<Map<String, dynamic>> monthlySalesData = [];
  String getMonthName(int monthIndex) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[monthIndex - 1];
  }

  bool isWithinLast12Months(String date) {
    DateTime currentDate = DateTime.now();
    DateTime givenDate = DateTime.parse(date);

    DateTime twelveMonthsAgo =
        currentDate.subtract(const Duration(days: 30 * 12));

    return givenDate.isAfter(twelveMonthsAgo) &&
        givenDate.isBefore(currentDate);
  }

  final currentMonth = DateTime.now().month;

  int startMonthIndex =
      currentMonth < 12 ? currentMonth + 1 : currentMonth - 11;

  monthlySalesData = List.generate(12, (index) {
    final monthIndex =
        startMonthIndex <= 12 ? startMonthIndex : startMonthIndex - 12;
    startMonthIndex++;
    return {'month': getMonthName(monthIndex), 'sales': 0.0};
  });

  for (var bill in billMaster) {
    String billDate = bill['Bill Date '];
    String billAmount = bill['Bill Amount '];
    final yearMonth = billDate.split('-');
    if (yearMonth.length == 3) {
      final month = int.tryParse(yearMonth[1]);
      if (isWithinLast12Months(billDate)) {
        if (month != null && month >= 1 && month <= 12) {
          monthlySalesData[month - 1]['sales'] += double.parse(billAmount);
        }
      }
    }
  }

  return SfCartesianChart(
    tooltipBehavior: TooltipBehavior(
      enable: true,
    ),
    legend: const Legend(
      isVisible: true,
    ),
    primaryXAxis: CategoryAxis(
      labelStyle: const TextStyle(fontSize: 8.0),
      maximumLabels: 12,
      labelRotation: -45,
    ),
    series: <CartesianSeries<Map<String, dynamic>, String>>[
      LineSeries<Map<String, dynamic>, String>(
        animationDuration: 0,
        dataSource: monthlySalesData,
        xValueMapper: (data, _) => data['month'],
        yValueMapper: (data, _) => data['sales'],
        name: 'Monthly Sales',
        dataLabelSettings: const DataLabelSettings(isVisible: true),
        enableTooltip: true,
      ),
    ],
  );
}

Widget buildBillerPerformancePieChart(List billMaster) {
  Map<String, double> billerSalesMap = {};

  DateTime today = DateTime.now();
  DateTime currentDate = DateTime(today.year, today.month, today.day);

  for (var bill in billMaster) {
    final billDate = DateTime.parse(bill['Bill Date ']);
    if (billDate.isAtSameMomentAs(currentDate)) {
      final billerId = bill['User Id '];
      final billAmount = double.parse(bill['Bill Amount ']);

      if (billerId != null) {
        if (billerSalesMap.containsKey(billerId)) {
          billerSalesMap[billerId] =
              (billerSalesMap[billerId] ?? 0) + billAmount;
        } else {
          billerSalesMap[billerId] = billAmount;
        }
      }
    }
  }

  final billerData = billerSalesMap.entries.map((entry) {
    return {'label': entry.key, 'value': entry.value};
  }).toList();

  Color getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  return SfCircularChart(
    tooltipBehavior: TooltipBehavior(enable: true),
    legend: const Legend(isVisible: true),
    title: ChartTitle(text: 'Today\'s Biller Performance'),
    series: <CircularSeries<Map<String, dynamic>, String>>[
      DoughnutSeries<Map<String, dynamic>, String>(
        dataSource: billerData,
        xValueMapper: (data, _) => data['label'] ?? '',
        yValueMapper: (data, _) => data['value'] ?? 0,
        dataLabelMapper: (data, _) => data['label'],
        dataLabelSettings: const DataLabelSettings(isVisible: true),
        enableTooltip: true,
        pointColorMapper: (data, _) => getRandomColor(),
      ),
    ],
  );
}

Widget buildBillerPerformanceBarChart(List billMaster) {
  Map<String, double> performanceData = {};

  DateTime now = DateTime.now();
  int currentMonth = now.month;
  int currentYear = now.year;

  List currentMonthBills = billMaster.where((bill) {
    DateTime billDate = DateTime.parse(bill['Bill Date ']);
    return billDate.year == currentYear && billDate.month == currentMonth;
  }).toList();
  for (var bill in currentMonthBills) {
    final billerId = bill['User Id '];
    final billAmount = double.parse(bill['Bill Amount ']);

    if (billerId != null) {
      if (performanceData.containsKey(billerId)) {
        performanceData[billerId] =
            (performanceData[billerId] ?? 0) + (billAmount);
      } else {
        performanceData[billerId] = billAmount;
      }
    }
  }

  final billerData = performanceData.entries.map((entry) {
    return {'label': entry.key, 'value': entry.value};
  }).toList();

  Color getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  return SfCartesianChart(
    primaryXAxis: CategoryAxis(
      labelStyle: const TextStyle(fontSize: 8.0),
      maximumLabels: 12,
      labelRotation: -45,
    ),
    series: <CartesianSeries<Map<String, dynamic>, String>>[
      ColumnSeries<Map<String, dynamic>, String>(
        dataSource: billerData,
        xValueMapper: (data, _) => data['label'],
        yValueMapper: (data, _) => data['value'],
        name: 'Biller Performance',
        dataLabelSettings: const DataLabelSettings(isVisible: true),
        enableTooltip: true,
        pointColorMapper: (data, _) => getRandomColor(),
      ),
    ],
  );
}
