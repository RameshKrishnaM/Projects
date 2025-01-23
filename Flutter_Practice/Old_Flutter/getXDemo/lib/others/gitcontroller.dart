import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:getxdemo/others/student.dart';

class Mycontroller extends GetxController {
  var student = Student();

  var count = 0.obs;
  var formController = TextEditingController();

  increment() {
    count++;
    update(['Running']);
  }

  void cleanUpTask() {
    print('Cleaning Process Compleated');
  }

  @override
  void onInit() {
    super.onInit();
    // print('OnInit Called');
    // ever(count, (callback) => print(count));
    // everAll([count], (callback) => print(count));
    // once(count, (callback) => print(count));
    print(count);
    interval(count, (callback) => print('clicking'),
        time: Duration(seconds: 3));
    debounce(
      count,
      (_) => print('print when the user stop typing for 3 seconds'),
      time: Duration(seconds: 3),
    );
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
  // changeToUpperCase() {
  //   student.name.value = student.name.value.toUpperCase();
  // }

  // changeToLowerCase() {
  //   student.name1.value = student.name1.value.toLowerCase();
  // }

  // increasAge() {
  //   student.age = student.age++;
  // }

  // decreaseAge() {
  //   student.age1 = student.age1--;
  // }
}
