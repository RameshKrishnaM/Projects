//2.--------------------------------------
import 'dart:io';

void main() {
  print('Enter the Length of the List');
  int n = int.parse(stdin.readLineSync()!);
  print('Enter the 1st List of Integer ');
  List<int> l1 = [];
  for (int i = 0; i < n; i++) {
    l1.add(int.parse(stdin.readLineSync()!));
  }
  print('Enter the 2nd List of Integer ');
  List<int> l2 = [];
  for (int i = 0; i < n; i++) {
    l2.add(int.parse(stdin.readLineSync()!));
  }
  var num1 = 0;
  var num2 = 0;
  List l3 = [];
  for (int i = l1.length - 1; i >= 0; i--) {
    num1 = num1 * 10 + l1[i];
  }
  for (int i = l2.length - 1; i >= 0; i--) {
    num2 = num2 * 10 + l2[i];
  }
  int result = num1 + num2;
  while (result > 0) {
    int rem = result % 10;
    l3.add(rem);
    result = result ~/ 10;
  }
  print(l3);
}
