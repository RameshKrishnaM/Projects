import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:novo/utils/colors.dart';

import '../../../model/mfModels/mf_pieChart_Model.dart';
import '../../NOVO Widgets/validationformat.dart';

void showAssetOverviewDailog(
    BuildContext context, MFpieChartDetails mFpieChartDetails) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24.0))),
        // titlePadding: const EdgeInsets.only(right: 10, top: 10),
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     InkWell(
        //         onTap: () => Navigator.pop(context),
        //         child: const Icon(
        //           Icons.close,
        //           size: 20,
        //         ))
        //   ],
        // ),
        contentPadding: EdgeInsets.zero,
        content: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Text('Asset Overview',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontSize: 12)),
              Text(
                  '₹ ${doubleformatAmount(mFpieChartDetails.mfschemetotal ?? 0.0)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(
                height: 200,
                width: 150,
                child: DonutChart(
                  mFpieChartDetails: mFpieChartDetails,
                ),
              ),
              Container(
                  height: mFpieChartDetails.mfschemetype!.length <= 5
                      ? mFpieChartDetails.mfschemetype!.length * 30
                      : 150,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: mFpieChartDetails.mfschemetype!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 45.0, right: 45.0, bottom: 5, top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                                text: TextSpan(children: [
                              WidgetSpan(
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  alignment: Alignment.topLeft,
                                  margin: const EdgeInsets.only(right: 10),
                                  color: Color(int.parse(mFpieChartDetails
                                      .mfschemecolor![index]
                                      .replaceFirst('#', '0xff'))),
                                ),
                              ),
                              WidgetSpan(
                                  child: Text(
                                mFpieChartDetails.mfschemetype![index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontSize: 11),
                              )),
                            ])),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Container(
                            //       height: 10,
                            //       width: 10,
                            //       margin: const EdgeInsets.only(right: 10),
                            //       color: Color(int.parse(mFpieChartDetails
                            //           .mfschemecolor![index]
                            //           .replaceFirst('#', '0xff'))),
                            //     ),
                            //     Text(
                            //       mFpieChartDetails.mfschemetype![index],
                            //       style: Theme.of(context)
                            //           .textTheme
                            //           .bodySmall!
                            //           .copyWith(fontSize: 11),
                            //     ),
                            //   ],
                            // ),

                            // const Expanded(child: SizedBox()),
                            Text(
                                '${mFpieChartDetails.mfschemepercentage![index].toString()} %',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                        color: primaryRedColor.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24))),
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: primaryRedColor,
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class DonutChart extends StatefulWidget {
  final MFpieChartDetails mFpieChartDetails;
  const DonutChart({super.key, required this.mFpieChartDetails});
  @override
  _DonutChartState createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  _touchedIndex = -1;
                  return;
                }
                _touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          sections: _buildPieChartSections(),
          centerSpaceRadius: 30,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    List<PieChartSectionData> sections = [];
    for (int i = 0; i < widget.mFpieChartDetails.mfschemetype!.length; i++) {
      sections.add(
        PieChartSectionData(
          titlePositionPercentageOffset: 0.5,
          color: Color(int.parse(widget.mFpieChartDetails.mfschemecolor![i]
              .replaceFirst('#', '0xff'))),
          value: widget.mFpieChartDetails.mfschemepercentage![i] is num
              ? widget.mFpieChartDetails.mfschemepercentage![i].toDouble()
              : 0,
          title: _touchedIndex == i
              ? '${widget.mFpieChartDetails.mfschemepercentage![i]}%'
              : '',
          radius: _touchedIndex == i ? 60 : 50,
          titleStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: titleTextColorDark,
          ),
        ),
      );
    }
    return sections;
  }
}
