// import 'dart:io';

// void main() {
//   print("Enter name:");
//   String? name  = stdin.readLineSync();
//   print("The entered name is ${name}");
// }
// void main() {
//   String str = "Ramesh";
//   //  print(str.codeUnits);   //Example of code units
//   //  print(str.isEmpty);     //Example of isEmpty
//   //  print(str.isNotEmpty);  //Example of isNotEmpty
//   //  print("The length of the string is: ${str.length}");   //Example of Length
//   // print(str.split('').reversed.join());
//   // print('''Hello i'am "Ramesh Krishna"''');

// }

// void main() {
//    var age = 22;
//    assert(age!=20, "Age must be 22");
// }

// void main(){
//     List<String> footballplayers=['Ronaldo','Messi','Neymar','Hazard'];

//   for(String player in footballplayers){
//     print(player);
//   }
// }

// import 'dart:math';

// void main() {
//   Random random = new Random();
//   double randomNumber = random.nextDouble() * 10; // from 0.0 to 10.0 included
//   print("Generated Random Number Between 0 to 9: $randomNumber");

//   int randomNumber2 = random.nextInt(10) + 1; // from 1 to 10 included
//   print("Generated Random Number Between 1 to 10: $randomNumber2");
//   print(random.nextBool());
// }

// void main() {
//    List<String> drinks = ["water", "juice", "milk", "coke"];
//    List<int>  ages = [];
//    print("Is drinks Empty: "+ drinks.isEmpty.toString());
//    print("Is drinks not Empty: "+drinks.isNotEmpty.toString());
//    print("Is ages Empty: "+ages.isEmpty.toString());
//    print("Is ages not Empty: "+ages.isNotEmpty.toString());

// }

// void main() {
//   List<int> list = list<int> filled(3,3);

//   list.forEach((n) => print(n*2));
// }

// import 'package:test/test.dart';

// void main() {
//   a() => print('c');
// }

// import 'dart:io';

// void main(List<String> args) {
//   String? password = '';
//   password = stdin.readLineSync();

// }

//---------------------------------------
void main(List<String> args) {
  Map map1 = {
    'a': 1,
    'b': {
      'c': 2,
      'd': {'e': 3},
    },
  };
  // for (int i = 0; i < map1.length; i++) {
    print(map1[1](1));
  // }
}
