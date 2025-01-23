import 'dart:io';

bool prime(int num) {
  int count = 0;
  for (int i = 1; i <= num; i++) {
    if (num % i == 0) {
      count++;
      if (count > 2) {
        break;
      }
    }
  }
  if (count == 2) {
    return true;
  } else {
    return false;
  }
}

void main(List<String> args) {
  int n = int.parse(stdin.readLineSync()!);
  if (n == 0 || n == 1) {
    print('Neither Prime Nor Composite');
  }

  for (int num = 2; num <= n; num++) {
    if (prime(num)) {
      print(num);
    }
  }
}
