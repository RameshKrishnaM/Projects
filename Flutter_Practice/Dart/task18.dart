//5.------------------------------------------
import 'dart:io';

void main() {
  print('Enter the Length of the List');
  int n = int.parse(stdin.readLineSync()!);

  print('Enter the List of Integer ');
  List<int> l1 = [];

  for (int i = 0; i < n; i++) {
    l1.add(int.parse(stdin.readLineSync()!));
  }

  print('Enter the number of times you want to rotate');
  int rotate = int.parse(stdin.readLineSync()!);
  int last;
  for (int i = 0; i < rotate; i++) {
    last = l1[l1.length - 1];
    for (int j = l1.length - 1; j > 0; j--) {
      l1[j] = l1[j - 1];
    }
    l1[0] = last;
  }
  print(l1);
}
