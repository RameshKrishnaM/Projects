// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:novo/widgets/MF%20Widgets/Mf_Button_Widget.dart';
import 'package:path_provider/path_provider.dart';

import '../../../cookies/cookies.dart';
import '../../../utils/colors.dart';
import '../../NOVO Widgets/snackbar.dart';

enum DateShareMethod { alldate, dateRange }

class DatePickerForm extends StatefulWidget {
  const DatePickerForm({super.key});

  @override
  State<DatePickerForm> createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<DatePickerForm> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _endDate;
  DateShareMethod dateMethod = DateShareMethod.alldate;
  bool dwnlLoading = false;

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isStartDate) async {
    DateTime today = DateTime.now();
    DateTime firstDate =
        DateTime(2000, 1, 1); // Set the initial first date to Jan 1, 2000
    DateTime lastDate = today; // Set the last date to today

    // Adjust the lastDate for start date picker based on the selected end date
    if (isStartDate && _endDate != null) {
      lastDate = _endDate!;
      // Ensure the initial date is within the valid range
      if (today.isAfter(lastDate)) {
        today = lastDate;
      }
    }

    // Adjust the firstDate for end date picker based on the selected start date
    if (!isStartDate && _fromDate != null) {
      firstDate = _fromDate!;
      // Ensure the initial date is within the valid range
      if (today.isBefore(firstDate)) {
        today = firstDate;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fromDate = picked;
          controller.text = "${_fromDate!.toLocal()}".split(' ')[0];
          _endDateController.clear(); // Clear end date if the from date changes
          _endDate = null;
        } else {
          _endDate = picked;
          controller.text = "${_endDate!.toLocal()}".split(' ')[0];
        }
      });
    }
  }

  Future<void> _downloadCsv(context) async {
    setState(() {
      dwnlLoading = true;
    });
    int id = DateTime.now().millisecond;
    bool permission = await AwesomeNotifications().isNotificationAllowed();
    if (!permission) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
      permission = await AwesomeNotifications().isNotificationAllowed();
    }
//file.path.split("/").last
    try {
      if (permission) {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                // groupKey: "progress",
                id: id,
                channelKey: 'alerts',
                title: 'File Downloading',
                body: "",
                // largeIcon: 'asset://assets/Completed.png',
                notificationLayout: NotificationLayout.ProgressBar,
                payload: {'notificationId': '1234567890'},
                locked: true));
      }

      var response = await postMethod(
        'mf/transactiondata',
        jsonEncode({
          "fromdate": dateMethod == DateShareMethod.alldate
              ? ''
              : _startDateController.text,
          "todate": dateMethod == DateShareMethod.alldate
              ? ''
              : _endDateController.text,
          "rangetype": dateMethod == DateShareMethod.alldate ? 'N' : 'YD'
        }),
        context,
      );

      if (response != null && response.statusCode == 200) {
        final responsedata = jsonDecode(response.body);

        if (responsedata['mfTransactionHisData'] == null) {
          // Show an error message when mfTransactionData is null
          if (permission) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                  // groupKey: "file",
                  id: id,
                  channelKey: 'alerts',
                  title: 'Download Failed',
                  body: "",
                  largeIcon: 'asset://assets/Error.png',
                  notificationLayout: NotificationLayout.BigText,
                  locked: false),
            );
          }
          showSnackbar(context, "Data Unavailable for Particular Date Range",
              primaryRedColor);
        } else {
          // Assuming mfTransactionData is a List
          final List<dynamic> mfTransactionData =
              responsedata['mfTransactionHisData'];

          // Convert the List to CSV
          final String csvData = _convertListToCsv(mfTransactionData);

          // Saving the CSV file locally
          await _saveCsvFile(csvData, id, permission, context);
        }
      } else {
        if (permission) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
                // groupKey: "file",
                id: id,
                channelKey: 'alerts',
                title: 'Download Failed',
                body: "",
                largeIcon: 'asset://assets/Error.png',
                notificationLayout: NotificationLayout.BigText,
                locked: false),
          );
        }
        showSnackbar(context, "Server Busy...", primaryRedColor);
      }
    } catch (e) {
      if (permission) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
              // groupKey: "file",
              id: id,
              channelKey: 'alerts',
              title: 'Download Failed',
              body: "",
              largeIcon: 'asset://assets/Error.png',
              notificationLayout: NotificationLayout.BigText,
              locked: false),
        );
      }
      showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
    } finally {
      setState(() {
        dwnlLoading = false;
      });
      Navigator.pop(context);
    }
  }

  String _convertListToCsv(List<dynamic> dataList) {
    // Assuming each element in dataList is a Map with String keys
    if (dataList.isEmpty) return '';

    // Extract the header row
    final header = dataList.first.keys.join(',');

    // Convert each map to a comma-separated line
    final rows = dataList.map((item) {
      return item.values.map((value) => '"${value.toString()}"').join(',');
    }).join('\n');

    // Combine the header and rows
    return '$header\n$rows';
  }

  Future<void> _saveCsvFile(
      String csvData, int id, bool permission, context) async {
    try {
      Directory? dir;

      if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        dir = await getDownloadsDirectory();
        Directory path = Directory("/storage/emulated/0/Download");

        if (!path.existsSync()) {
          await path.create(recursive: true);
        }
        dir = path;
      }

      String title = 'transaction_details';
      File file = File("${dir!.path}/$title.csv");

      // Handle file name conflicts by appending a number
      if (file.existsSync()) {
        for (int i = 1; true; i++) {
          File file1 = File("${dir.path}/$title($i).csv");
          if (!file1.existsSync()) {
            file = file1;
            break;
          }
        }
      }

      // Write the CSV data to the file
      await file.writeAsString(csvData);
      if (permission) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
              // groupKey: "file",
              id: id,
              channelKey: 'alerts',
              title: 'File Downloaded',
              body: file.path.split("/").last,
              largeIcon: 'asset://assets/Completed.png',
              notificationLayout: NotificationLayout.BigText,
              payload: {'filePath': file.path},
              locked: false),
        );
      }

      // Show a snackbar to indicate success
      // showSnackbar(
      //     context,
      //     "Downloaded successfully: ${file.path.split('/').last}",
      //     Colors.green);
    } catch (e) {
      // Log the error and show a failure message
      if (permission) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
              // groupKey: "file",
              id: id,
              channelKey: 'alerts',
              title: 'Download Failed',
              body: "",
              largeIcon: 'asset://assets/Error.png',
              notificationLayout: NotificationLayout.BigText,
              locked: false),
        );
      }
      // showSnackbar(context, "Failed to download file", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio<DateShareMethod>(
                value: DateShareMethod.alldate,
                groupValue: dateMethod,
                activeColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue
                    : appPrimeColor,
                onChanged: (DateShareMethod? value) {
                  setState(() {
                    dateMethod = value!;
                    _startDateController.text = '';
                    _endDateController.text = '';
                  });
                },
              ),
              const Text('All Transactions'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio<DateShareMethod>(
                value: DateShareMethod.dateRange,
                groupValue: dateMethod,
                activeColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue
                    : appPrimeColor,
                onChanged: (DateShareMethod? value) {
                  setState(() {
                    dateMethod = value!;
                  });
                },
              ),
              const Text('Transactions by Date Range'),
            ],
          ),
          Visibility(
              visible: dateMethod == DateShareMethod.dateRange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        controller: _startDateController,
                        readOnly: true,
                        onTap: () => dateMethod == DateShareMethod.alldate
                            ? null
                            : _selectDate(context, _startDateController, true),
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_month),
                            prefixIconColor: subTitleTextColor,
                            contentPadding: const EdgeInsets.all(10),
                            hintText: 'From Date',
                            isDense: true,
                            prefixIconConstraints:
                                BoxConstraints.tight(const Size(30, 40)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: subTitleTextColor),
                                borderRadius: BorderRadius.circular(5)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: subTitleTextColor),
                                borderRadius: BorderRadius.circular(5)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: subTitleTextColor),
                                borderRadius: BorderRadius.circular(5))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        // autovalidateMode: ,
                        // textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => dateMethod == DateShareMethod.alldate
                            ? null
                            : _selectDate(context, _endDateController, false),
                        decoration: InputDecoration(
                            hintText: 'To Date',
                            prefixIcon: const Icon(Icons.calendar_month),
                            prefixIconColor: subTitleTextColor,
                            prefixIconConstraints:
                                BoxConstraints.tight(const Size(30, 40)),
                            contentPadding: const EdgeInsets.all(10),
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: subTitleTextColor),
                                borderRadius: BorderRadius.circular(5)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: subTitleTextColor),
                                borderRadius: BorderRadius.circular(5)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: subTitleTextColor),
                                borderRadius: BorderRadius.circular(5))),
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                backgroundColor: appPrimeColor,
                isSmall: true,
                buttonWidget: dwnlLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: titleTextColorDark,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.download,
                              size: 13, color: titleTextColorDark),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            'Download',
                            style: TextStyle(
                                color: titleTextColorDark, fontSize: 12),
                          )
                        ],
                      ),
                onTapFunc: () {
                  _downloadCsv(context);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
