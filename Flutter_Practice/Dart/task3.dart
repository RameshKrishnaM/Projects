// class home {
//   String? name, Address;
//   int? no_Of_Rooms;
//   home(this.name, this.Address, this.no_Of_Rooms);
//   // {
//   // this.name = name;
//   // this.Address = Address;
//   // this.no_Of_Rooms = no_Of_Rooms;
//   // }

//   void display() {
//     print("Name        :$name");
//     print("Address     :$Address");
//     print("NO Of Rooms :$no_Of_Rooms");
//   }
// }

// void main(List<String> args) {
//   home h = home("Krish", "Tirunelveli", 3);

//   h.display();
// }

// import 'dart:math';

// void main(List<String> args) {
//   Random r = Random();
//   List<String> allalphabets = 'abcdefghijklmnopqrstuvwxyz'.split('');
//   List<String> password = [];
//   password.add(allalphabets[r.nextInt(allalphabets.length)]);
//   print(password);
// }

// import 'dart:math';

// void main(List<String> args) {
//   Random r = Random();
//   int min = 100;
//   int max = 1000;
//   int count = 0;
//   for (int i = min; i < max; i++) {
//     var emoji = String.fromCharCode(0x1F200 + i);
//     print(emoji);
//     count++;
//   }
//   print(count);
// var k = 0;
// for (int i = 0; i < 20; i++) {
//   print(String.fromCharCode(0x1F600 + k));
//   k++;
// }
//  print(String.fromCharCode(0x1F613));
// Runes r = Runes('😍');
// print(r);
// }

// import 'dart:math';

// void main(List<String> args) {
//   List l1 = ['R', 'P', 'S'];
//   Random r = Random();
//   print(l1[r.nextInt(l1.length)]);

// }

// void main() {
//   int n = 10;
//   for (int i = 1; i <= n; i++) {
//     if (n % i == 0) {
//       print(i);
//     } else {
//       print('not prime');
//     }
//   }
// }

// import 'dart:io';

// void main(List<String> args) {
//   int n = 5;
//   int k = 1;
//   int a = 0;
//   for (int i = 0; i < n; i++) {
//     for (int j = 0; j < n; j++) {
//       if (i > j) {
//         stdout.write('$k ');
//         k--;
//       } else {
//         stdout.write(' ');
//       }
//     }
//     print('');
//     k = a + 1;
//     a++;
//   }
// }

// void main() {
// List l1 = [1, 0, 3, 7, 0, 4];
// List l2 = List.filled(l1.length, 0);
// int n = 0;
// for (int i = 0; i < l1.length; i++) {
//   if (l1[i] != 0) {
//     l2[n++] = l1[i];
//   }
// }
// print(l2);
// }

// void main() {
//   List l1 = [
//     [1, 2, 3],
//     [4, 5, 6],
//     [7, 8, 9]
//   ];
//   List l2 = [
//     [0, 0, 0],
//     [0, 0, 0],
//     [0, 0, 0]
//   ];
//   int i2 = 0;
//   for (List e in l2) {
//     int a = 0;
//     for (int i = 0; i < e.length; i++) {
//       e[i] = l1[a++][i2];
//     }
//     i2++;
//   }
//   print(l2);
// }



