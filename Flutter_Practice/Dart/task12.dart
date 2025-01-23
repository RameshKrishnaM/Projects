// import 'dart:io';

// void main(List<String> args) {
//   print('Enter a number for tables');
//   int n = int.parse(stdin.readLineSync()!);
//   print('Enter the range');
//   int k = int.parse(stdin.readLineSync()!);
//   for (int i = 1; i <= k; i++) {
//     print('$i * $n = ${i * n}');
//   }
// }

//----------------------------------------------------

// import 'dart:io';

// void main(List<String> args) {
//   print('Enter a pargraph');
//   String str = stdin.readLineSync()!.replaceAll(' ', '').toLowerCase();
//   print(isPanogram(str));
// }

// bool isPanogram(String str) {
//   List s = 'abcdefghijklmnopqrstuvwxyz'.split('');
//   for (var e in s) {
//     if (!str.contains(e)) {
//       return false;
//     }
//   }
//   return true;
// }
