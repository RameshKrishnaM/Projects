import 'dart:io';

void main(List<String> args) {
  int a = 0;
  int b = 1;
  int c;
  print('Enter a number');
  int n = int.parse(stdin.readLineSync()!);
  if (n == 1) {
    print(a);
  } else if (n == 2) {
    print(a);
    print(b);
  } else {
    print(a);
    print(b);
    for (int i = 3; i <= n; i++) {
      c = a + b;
      print(c);
      a = b;
      b = c;
    }
  }
}
