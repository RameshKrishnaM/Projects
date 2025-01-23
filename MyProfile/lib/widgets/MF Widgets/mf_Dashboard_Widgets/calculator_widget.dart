import 'package:flutter/material.dart';
import 'package:novo/widgets/MF%20Widgets/mf_Dashboard_Widgets/calcluator_value_Container.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../utils/colors.dart';
import 'MfCalculatorslider.dart';

class MfCustomCalculator extends StatefulWidget {
  const MfCustomCalculator({super.key});

  @override
  State<MfCustomCalculator> createState() => _MfCustomCalculatorState();
}

class _MfCustomCalculatorState extends State<MfCustomCalculator> {
  TextEditingController amountController = TextEditingController();
  double amount = 0;
  double returns = 0;
  double years = 0;
  double invested = 0;
  double estimated = 0;
  double total = 0;

  String calculatorType = "Lumpsum";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ListView(
            children: [
              const SizedBox(height: 10.0),
              SizedBox(
                height: 33.0,
                width: MediaQuery.of(context).size.width - 30.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ["Lumpsum", "SIP", "Cost"]
                      .map((type) => Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: InkWell(
                              onTap: () {
                                calculatorType = type;
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
                                decoration: BoxDecoration(
                                    color: calculatorType == type
                                        ? appPrimeColor
                                        : null,
                                    borderRadius: BorderRadius.circular(7.0),
                                    border: calculatorType == type
                                        ? null
                                        : Border.all(
                                            color: subTitleTextColor,
                                            width: 1.0)),
                                child: Text(
                                  type,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: calculatorType == type
                                          ? titleTextColorDark
                                          : null),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10.0),
              const Text("Amount",
                  style:
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                      child: CustomSlider(
                    min: 0,
                    max: 10000000,
                    value: amount,
                    onChangeFunc: (value) {
                      amount = value;
                      setState(() {});
                    },
                  )),
                  CalculatorValueContainer(
                      text: "₹${amount.round()}",
                      backGroundColor: modifyButtonColor,
                      textColor: appPrimeColor)
                ],
              ),
              const SizedBox(height: 5.0),
              const Text("Returns",
                  style:
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                      child: CustomSlider(
                          value: returns,
                          onChangeFunc: (value) {
                            returns = value;
                            setState(() {});
                          },
                          min: 0,
                          max: 30)),
                  CalculatorValueContainer(
                    text: "${returns.toStringAsFixed(1)}%",
                    backGroundColor: inactiveColor,
                  )
                ],
              ),
              const Text("Years",
                  style:
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                      child: CustomSlider(
                    min: 0,
                    max: 40,
                    value: years,
                    onChangeFunc: (value) {
                      years = value;
                      setState(() {});
                    },
                  )),
                  CalculatorValueContainer(
                    text: "${years.round()} Years",
                    backGroundColor: inactiveColor,
                  )
                ],
              ),
              const SizedBox(height: 10.0),
              ...{
                "Invested Amount : ": 1000.0,
                "Estimated Return : ": 1000.0,
                "Total Value : ": 1000.0
              }.keys.map((amounts) => Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          amounts,
                          style: TextStyle(
                              fontSize: 15.0, color: subTitleTextColor),
                        )),
                        Text(
                          "₹${years.round()}",
                          style: const TextStyle(
                              fontSize: 17.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Container(
                    height: 8.0,
                    width: 17.0,
                    decoration: BoxDecoration(
                        color: appPrimeColor,
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                  const SizedBox(width: 5.0),
                  const Text("Invested"),
                  const SizedBox(width: 20.0),
                  Container(
                    height: 8.0,
                    width: 17.0,
                    decoration: BoxDecoration(
                        color: modifyButtonColor,
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                  const SizedBox(width: 5.0),
                  const Text("Estimated returns"),
                ],
              ),
              const SizedBox(height: 20.0),
              SfCircularChart(
                palette: [modifyButtonColor, appPrimeColor],
                series: [
                  DoughnutSeries<ChartData, String>(
                    dataSource: [
                      ChartData('Invested', 35),
                      ChartData('Estimated returns', 28),
                    ],
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.value,
                    dataLabelSettings:
                        const DataLabelSettings(isVisible: false),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.category, this.value);
  final String category;
  final double value;
}
