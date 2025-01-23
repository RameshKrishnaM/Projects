// // void main() {
// //   String myDatetime = "2023-09-27";
// //   DateTime convertDateTime = DateTime.parse(myDatetime);
// //   print("Day   =  ${convertDateTime.day.toString()}");
// //   print("Month =  ${convertDateTime.month.toString()}");
// //   print("year  =  ${convertDateTime.year.toString()}");
// // }

// void main(List<String> args) {
//   DateTime myBday = DateTime.parse("2000-05-08");
//   DateTime anDate = DateTime.parse('2023-05-08');
//   DateTime today = DateTime.now();
//   Duration diff = anDate.difference(myBday);
//   print(diff);
//   print("Difference in days ${diff.inDays.toString()}");
//   print("Difference in Hours ${diff.inHours.toString()}");
// }

//   void add( num1,num2){
//    var sum =0;
//   sum = num1 + num2;

//    print("The sum is $sum");
// }

// void main(){
//   add("Ramesh"," Krishna");
//   add(10, 20);
// }

// import 'dart:isolate';
// void sayhii(var msg){
//    print('execution from sayhii ... the message is :$msg');
// }

// void main(){
//    Isolate.spawn(sayhii,'Hello!!');
//    Isolate.spawn(sayhii,'Whats up!!');
//    Isolate.spawn(sayhii,'Welcome!!');

//    print('execution from main1');
//    print('e main2');
//    print('execution from maixecution fromn3');
// }


// void main(List<String> args) {
//   DateTime d = DateTime.now();
//   print(d.weekday);
// }