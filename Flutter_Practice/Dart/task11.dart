import 'dart:io';

void main() {
  print('Enter Length of Pattern');
  int n = int.parse(stdin.readLineSync()!);
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (i + j >= n - 1) {
        stdout.write('* ');
      } else {
        stdout.write('  ');
      }
    }
    // for (int k = 0; k < n; k++) {
    //   if (i > k) {
    //     stdout.write('* ');
    //   } else {
    //     stdout.write('  ');
    //   }
    // }

    print('');
  }
}
