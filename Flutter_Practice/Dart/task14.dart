import 'dart:io';

void main() {
  String para = stdin.readLineSync()!;
  List para1 = [];
  String result = '';
  for (int i = 0; i < para.length; i++) {
    if (para.codeUnitAt(i) <= 90 && para.codeUnitAt(i) >= 65) {
      para1.add(String.fromCharCode(para.codeUnitAt(i) + 32));
    } else if (para.codeUnitAt(i) <= 122 && para.codeUnitAt(i) >= 97) {
      para1.add(String.fromCharCode(para.codeUnitAt(i)));
    }
  }

  for (int i = 0; i < para1.length; i++) {
    for (int j = i + 1; j < para1.length; j++) {
      if (para1[i] == para1[j]) {
        para1[j] = '';
        continue;
      }
    }
    result += para1[i];
  }
  print(result);
}
