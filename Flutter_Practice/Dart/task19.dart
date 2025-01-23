//6.-----------------------------------
import 'dart:io';

void main() {
  print('Enter the Length of the List');
  int n = int.parse(stdin.readLineSync()!);

  print('Enter the List of Integer ');
  List<int> l1 = [];

  for (int i = 0; i < n; i++) {
    l1.add(int.parse(stdin.readLineSync()!));
  }
  List l2 = [];
  int count = 0;
  for (int i = 0; i < l1.length; i++) {
    if (l1[i] == 0) {
      count++;
      continue;
    }
    l2.add(l1[i]);
  }
  for (int i = 0; i < count; i++) {
    l2.add(0);
  }
  print(l2);
}
