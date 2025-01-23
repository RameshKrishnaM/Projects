//3.-----------------------------------------------
import 'dart:io';

void main() {
  print('Enter the String ');
  String str = stdin.readLineSync()!;
  List l = str.split('');
  List l1 = [];
  for (int i = 0; i < l.length - 1; i++) {
    String s = l[i];
    for (int j = i + 1; j < l.length; j++) {
      if (l[i] != l[j]) {
        s += l[j];
        l[i] = l[j];
      } else {
        break;
      }
    }
    l1.add(s);
    s = '';
  }
  List<String> l2 = [];
  for (String e in l1) {
  String s = '';
    List l4 = e.split('');
    for (int i = 0; i < l4.length; i++) {
      for (int j = i + 1; j < l4.length; j++) {
        if (l4[i] == l4[j]) {
          l4[j] = '';
        }
      }
    }
    for (int a = 0; a < l4.length; a++) {
        if(l4[a] != ' '){
          s += l4[a];
        }
    }
    l2.add(s);
    l4 = [];
  }
  String large = l2[0];
  for (int i = 1; i < l2.length; i++) {
    if (large.length < l2[i].length) {
      large = l2[i];
    } else if (large.length == l2[i].length) {
      continue;
    }
  }
  print(
      '''Largest Substring of the String "$str" is "$large" with length "${large.length}"''');
}