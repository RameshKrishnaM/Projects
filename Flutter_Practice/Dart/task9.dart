//-------------------- Palindrome ------------------------------

// import 'dart:io';

// void main() {
//   print('Enter String');
//   var str = stdin.readLineSync()!;
//   print('Enter the Number ');
//   int num = int.parse(stdin.readLineSync()!);
//   strReverse(str);
//   numReverse(num);
// }

// void strReverse(str) {
//   var str1 = '';
//   for (int i = str.length - 1; i >= 0; i--) {
//     str1 = str1 + str[i];
//   }
//   print(str1);
//   if (str == str1) {
//     print('Palindrome');
//   } else {
//     print('Not Palindrome');
//   }
// }

// void numReverse(num) {
//   int temp = num;
//   int rev = 0;
//   while (num > 0) {
//     int rem = num % 10;
//     rev = rev * 10 + rem;
//     num = num ~/ 10;
//   }
//   print(rev);
//   if (temp == rev) {
//     print("palindrome");
//   } else {
//     print("not palindrome");
//   }
// }

//--------------------Factorial------------------------------

// import 'dart:io';

// void main() {
//   print("enter the Number");
//   int n = int.parse(stdin.readLineSync()!);
//   int mul = 1;
//   int pow = 0;
//   for (var i = 1; i <= n; i++) {
//     mul = mul * power(i, pow);
//     pow++;
//   }
//   print('Factorial of $n is $mul');
// }

// int power(int a, b) {
//   int res = 1;
//   for (int i = 1; i <= b; i++) {
//     res = res * a;
//   }
//   return res;
// }


//--------------------- GCD ------------------------------
import 'dart:io';

void main(List<String> args) {
  print('Enter 1st Number');
  int a = int.parse(stdin.readLineSync()!);
  print('Enter 2nd Number');
  int b = int.parse(stdin.readLineSync()!);

  while (b > 0) {
    int c = a % b;
    a = b;
    b = c;
  }
  print(a);
}
