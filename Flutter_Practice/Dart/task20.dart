//7.--------------------------------------
import 'dart:io';

void main() {
  print('Enter the Length of the List');
  int n = int.parse(stdin.readLineSync()!);

  print('Enter the List of Integer ');
  List<String> l1 = [];

  for (int i = 0; i < n; i++) {
    l1.add(stdin.readLineSync()!);
  }
  for (int i = 0; i < l1.length; i++) {
    for (int j = i + 1; j < l1.length; j++) {
      if (l1[i].length == l1[j].length) {
        int count = 0;
        for (int a = 0; a < l1[i].length; a++) {
          for (int b = 0; b < l1[j].length; b++) {
            if (l1[i][a] == l1[j][b]) {
              count++;
            }
          }
          if (count == l1[i].length) {
            print('${l1[i]} == ${l1[j]}');
          }
        }
      }
    }
  }
}

