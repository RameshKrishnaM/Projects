/*
1
01
010
1010
10101


*/

// import 'dart:io';

// void main(List<String> args) {
//   int n = 5;
//   int a = 1;
//   for (int i = 1; i <= n; i++) {
//     for (int j = 1; j <= i; j++) {
//       stdout.write(a % 2);
//       a++;
//     }
//     print('');
//   }
// }


//------------------------------------------------------------
/*
    1
   121
  12321
 1234321
123454321

*/
import 'dart:io';

void main() {
  int n = 5;
  int m = 1;
  int a = 0;
  for (int i = 0; i < n; i++) {
    int k = 1;
    for (int j = 0; j < n; j++) {
      if (i + j >= n - 1) {
        stdout.write('$k ');
        k++;
      } else {
        stdout.write('  ');
      }
    }
    
     for (int j = 0; j < n; j++) {
      if (i > j) {
        stdout.write('$m ');
        m--;
      } else {
        stdout.write(' ');
      }
    }
    print('');
    m = a + 1;
    a++;
  }
}
