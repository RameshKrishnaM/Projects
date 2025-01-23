//4.------------------------------------------
import 'dart:io';

void main() {
  print('Enter the Length of the List');
  int n = int.parse(stdin.readLineSync()!);
  print('Enter the List of Integer ');
  List<int> l1 = [];
  for (int i = 0; i < n; i++) {
    l1.add(int.parse(stdin.readLineSync()!));
  }
  List<int> result = [];

  for (int i = 0; i < l1.length; i++) {
    for (int j = i + 1; j < l1.length; j++) {
      if (l1[i] == l1[j]) {
        l1[j] = 0;
        break;
      }
    }
   if(l1[i] > 0){
    result.add(l1[i]);
   }
  }
  print(result);
}
