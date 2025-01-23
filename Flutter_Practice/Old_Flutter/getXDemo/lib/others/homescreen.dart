/* import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  var count = 0.obs;

  void increment() {
    count++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Text('Count Value is $count '),
            ),
            ElevatedButton(
              onPressed: () {
                // Get.snackbar(
                //   'SnackBar',
                //   'This is the SnackBar',
                // );
                Get.bottomSheet(BottomSheet(
                  onClosing: () {},
                  builder: (context) {
                    return Container(
                      child: Wrap(
                        children: [
                          // Text('Ramesh '),
                          // Text('Krishna'),
                          ListTile(
                            leading: Icon(Icons.wb_sunny_outlined),
                            title: Text('Light Theme'),
                            onTap: () {
                              print('Switching to Light Theme');
                              Get.changeTheme(ThemeData.light());
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.nightlight_round),
                            title: Text('Dark Theme'),
                            onTap: () {
                              print('Switching to Dark Theme');
                              Get.changeTheme(ThemeData.dark());
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ));
                // increment();
              },
              child: Text('Click Here'),
            ),
          ],
        ),
      ),
    );
  }
} */

//-------------------------------------------------------------------

/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:getxdemo/gitcontroller.dart';
import 'package:getxdemo/student.dart';

class Home extends StatelessWidget {
  Home({super.key});

  Mycontroller mycontroller1 = Get.put(Mycontroller());
  Mycontroller mycontroller2 = Get.put(Mycontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => Text('Name is ${mycontroller1.student.name}'),
          ),
          ElevatedButton(
            onPressed: () {
              mycontroller1.changeToUpperCase();
            },
            child: Text('Click to change UpperCase'),
          ),
          Obx(
            () => Text('Age is ${mycontroller1.student.age}'),
          ),
          ElevatedButton(
            onPressed: () {
              mycontroller1.increasAge();
            },
            child: Text('Click to increase'),
          ),
          Obx(
            () => Text('Name is ${mycontroller2.student.name1}'),
          ),
          ElevatedButton(
            onPressed: () {
              mycontroller2.changeToLowerCase();
            },
            child: Text('Click to change LowerCase'),
          ),
          Obx(
            () => Text('Age is ${mycontroller2.student.age1}'),
          ),
          ElevatedButton(
            onPressed: () {
              mycontroller2.decreaseAge();
            },
            child: Text('Click to Decrease'),
          ),
        ],
      ),
    );
  }
} */

//----------------------------------------------------------------------

/*

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:getxdemo/student.dart';

class Home extends StatelessWidget {
  Home({super.key});

  var student1 = Student('Ramesh', 24).obs;
  var student2 = Student('Krishna', 23).obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => Text('Name is ${student2.value.name}'),
          ),
          ElevatedButton(
            onPressed: () {
              student2.update((val) {
                if (student2.value.name
                    .contains(student2.value.name.toUpperCase())) {
                  student2.value.name = student2.value.name.toLowerCase();
                } else {
                  student2.value.name = student2.value.name.toUpperCase();
                }
              });
            },
            child: Text('Click to change'),
          ),
          Obx(
            () => Text('Age is ${student2.value.age}'),
          ),
          ElevatedButton(
            onPressed: () {
              student2.update((val) {
                student2.value.age = student2.value.age + 1;
              });
            },
            child: Text('Click to change'),
          ),
        ],
      ),
    );
  }
}

 */

//--------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getxdemo/others/gitcontroller.dart';

class HomeScreen2 extends StatelessWidget {
  Mycontroller mycontroller = Get.put(Mycontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // GetBuilder<Mycontroller>(
          //   // GetX(
          //   //   tag: 'txtCount',
          //   id: 'Running',
          //   // initState: (data) => mycontroller.increment(),
          //   // dispose: (_) => mycontroller.cleanUpTask(),
          //   builder: (controller) {
          //     return Text('The Value is ${controller.count}');
          //   },
          // ),
          // GetBuilder<Mycontroller>(
          //   // initState: (data) => mycontroller.increment(),
          //   // dispose: (_) => mycontroller.cleanUpTask(),
          //   builder: (controller) {
          //     return Text('The Value is ${controller.count}');
          //   },
          // ),
          SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
            onPressed: () {
              Get.find<Mycontroller>().increment();
              // mycontroller.increment();
            },
            child: Text('Update'),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextFormField(
            onChanged: (value) {
              mycontroller.increment();
            },
            controller: mycontroller.formController,
          ),
        ],
      ),
    );
  }
}




/*

Link(
                target: LinkTarget.self,
                uri: _url,
                builder: (context, followLink) {
                  return ElevatedButton(
                    onPressed: followLink,
                    child: Text('Click Here Link Widget'),
                  );
                },
              )


 */