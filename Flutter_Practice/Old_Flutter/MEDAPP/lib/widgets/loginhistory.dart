import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginHistory extends StatefulWidget {
  const LoginHistory({super.key});

  @override
  State<LoginHistory> createState() => _LoginHistoryState();
}

class _LoginHistoryState extends State<LoginHistory> {
  List<Map<String, dynamic>> loginHistory = [];
  List<Map<String, dynamic>> newLoginHistory = [];
  int rowsPerPage = -1;
  int currentPage = 1;
  String searchValue = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    String data = sref.getString('login History') ?? '[]';
    loginHistory = (jsonDecode(data) as List).cast<Map<String, dynamic>>();

    Map<String, dynamic> currentUserMap = {};

    for (var data in loginHistory) {
      final userId = data['User Id '] ?? '';
      final type = data['Type'];
      final date = data['Date'];

      if (type == 'Login') {
        currentUserMap = {'User Id ': userId, 'Login': date};
        newLoginHistory.add(currentUserMap);
      } else if (type == 'Logout') {
        if (currentUserMap['User Id '] == userId) {
          currentUserMap['Logout'] = date;
        }
      }
    }

    setState(() {});
  }

  List<Map<String, dynamic>> filterLoginHistoryBySearch(String searchValue) {
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < newLoginHistory.length; i++) {
      final userId = newLoginHistory[i]['User Id '] ?? '';
      String loginDateTime = newLoginHistory[i]['Login'] ?? '';
      String logoutDateTime = newLoginHistory[i]['Logout'] ?? '';

      final concatenatedValues = '$userId $loginDateTime $logoutDateTime';

      if (concatenatedValues
          .toLowerCase()
          .contains(searchValue.toLowerCase())) {
        Map<String, dynamic> record = {
          'User Id ': userId,
          'Login': loginDateTime,
          'Logout': logoutDateTime,
        };
        result.add(record);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filteredLoginHistory = filterLoginHistoryBySearch(searchValue);
    final totalPages = (filteredLoginHistory.length / rowsPerPage).ceil();

    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex =
        (currentPage * rowsPerPage).clamp(0, filteredLoginHistory.length);

    final pageItems = rowsPerPage == -1
        ? filteredLoginHistory
        : filteredLoginHistory.sublist(startIndex, endIndex);

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
                    currentPage = 1;
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
                  columnSpacing: 13.0,
                  columns: const [
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'User ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: pageItems.map((userData) {
                    return DataRow(
                      cells: [
                        DataCell(Text(userData['User Id '] ?? '')),
                        DataCell(Text(userData['Login'] ?? '')),
                        DataCell(Text(userData['Logout'] ?? '')),
                      ],
                    );
                  }).toList(),
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
