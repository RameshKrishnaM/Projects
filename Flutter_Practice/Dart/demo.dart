void main() {
  List<Map<String, dynamic>> originalData = [
    {
      "User Id ": "ramesh",
      "Type": "Login",
      "Date": "2023 - 10 - 27 / 17 : 3 : 52"
    },
    {
      "User Id ": "ramesh",
      "Type": "Logout",
      "Date": "2023 - 10 - 27 / 17 : 3 : 55"
    },
    {
      "User Id ": "krishna",
      "Type": "Login",
      "Date": "2023 - 10 -27 / 17 : 4 : 2"
    },
    {
      "User Id ": "krishna",
      "Type": "Logout",
      "Date": " 2023 - 10 - 27 / 17 : 4 : 5"
    },
    {
      "User Id ": "krish",
      "Type": "Login",
      "Date": "2023 - 10 - 27 / 17 : 4 : 12"
    },
    {
      "User Id ": "krish",
      "Type": "Logout",
      "Date": "2023 - 10 - 27 / 17 :4 : 23"
    },
    {
      "User Id ": "ramesh",
      "Type": "Login",
      "Date": "2023 - 10 - 27 / 17: 5 : 49"
    },
    {
      "User Id ": "ramesh",
      "Type": "Logout",
      'Date': "2023 -10 - 27 / 17 : 5 : 53"
    },
    {
      "User Id ": "krish",
      "Type": "Login",
      "Date": " 2023 - 10 - 27 / 17 : 6 : 1"
    },
    {
      "User Id ": "krish",
      "Type": "Login",
      "Date": "2023 - 10 - 27 / 17 : 7 : 31"
    }
  ];

  List<Map<String, dynamic>> finalResult = [];

  for (var data in originalData) {
    final userId = data['User Id '];
    final type = data['Type'];
    final date = data['Date'];

    final userMap =
        finalResult.firstWhere((map) => map['User Id '] == userId, orElse: () {
      final newUserMap = {'User Id': userId};
      finalResult.add(newUserMap);
      return newUserMap;
    });

    userMap[type] = date;
  }

  print(finalResult);
}
