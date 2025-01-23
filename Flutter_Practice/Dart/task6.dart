import 'dart:io';

void main(List<String> args) {
  int n = int.parse(stdin.readLineSync()!);
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (i == 0 ||
          i == n ~/ 2 ||
          i == n - 1 ||
          (j == 0 && i <= n / 2) ||
          (j == n - 1 && i >= n / 2)) {
        stdout.write("* ");
      } else {
        stdout.write("  ");
      }
    }
    print('');
  }
}

// void main() {
//   List l = [
//     {
//       'Name': 'Ramesh',
//       'Age': 23,
//       'Salary': {'Gross': 10000, 'Net': 8000}
//     },
//     {
//       'Name': 'Krishna',
//       'Age': 22,
//       'Salary': {'Gross': 10500, 'Net': 8050}
//     },
//     {
//       'Name': 'Kumar',
//       'Age': 24,
//       'Salary': {'Gross': 15000, 'Net': 11500}
//     }
//   ];
//  for (int i = 0; i < l.length ; i++) {
//     l[i]['Salary']['Gross'] += 2000;
//   }
//   print('$l');
// }

// void main() {
//   List l = [
//     {
//       'Name': 'Ramesh',
//       'Age': 23,
//       'Salary': {'Gross': 10000, 'Net': 8000}
//     },
//     {
//       'Name': 'Krishna',
//       'Age': 22,
//       'Salary': {'Gross': 10500, 'Net': 8050}
//     },
//     {
//       'Name': 'Kumar',
//       'Age': 24,
//       'Salary': {'Gross': 15000, 'Net': 11500}
//     }
//   ];

//   for (var item in l) {
//     print('Name : ${item['Name']} Gross : ${item['Salary']['Gross'] += 2000}');
//   }

//   print(l);
// }

// void main(List<String> args) {
// //   int n = int.parse(stdin.readLineSync()!);
//   int n = 9;
//   String m = '';
//   for (int i = 0; i < n; i++) {
//     for (int j = 0; j < n; j++) {
//       if (i == 0 ||
//           i == n ~/ 2 ||
//           i == n - 1 ||
//           (j == 0 && i <= n / 2) ||
//           (j == n - 1 && i >= n / 2)) {
//         m += '*';
//       } else {
//         m += " ";
//       }
//     }
//     m += '\n';
//   }
//   print(m);
// }

// void main() async {
//   print(await fetchword());
// }

// Future<String> fetchword() {
//   return Future.delayed(
//       Duration(seconds: 5), ()=> 'value');
// }

// void main(List<String> args) {
//   power(5, 4);
// }

// void power(a, b) {
//   int res = 1;
//   int k = a;
//   for (int i = 1; i <= b; i++) {
//     res = res * k;
//   }
//   print(res);
// }
