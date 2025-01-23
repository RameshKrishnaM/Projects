import 'dart:io';

void main() {
  print('Enter the first Number');
  int fnum = int.parse(stdin.readLineSync()!);
  print('Enter the second Number');
  int snum = int.parse(stdin.readLineSync()!);
  int n;
  int gcd = 0;
  if (fnum > snum) {
    n = fnum;
  } else {
    n = snum;
  }
  for (int i = n; i >= 1; i--) {
    if (fnum % i == 0 && snum % i == 0) {
      gcd = i;
      break;
    }
  }
  print('GCD of $fnum and $snum is $gcd');
}