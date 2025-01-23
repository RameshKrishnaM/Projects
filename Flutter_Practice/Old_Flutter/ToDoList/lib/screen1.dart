import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/customwidget.dart';
import 'package:todolist/demo.dart';
import 'package:todolist/providerclass.dart';
import 'package:todolist/todoclass.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final toDoList = ToDo.toDoList();
  TextEditingController todoController = TextEditingController();
  List<String> deletedItems = [];
  final todoKey = GlobalKey<FormState>();

  adding() {
    toDoList.insert(
      0,
      ToDo(
          id: (int.parse(ToDo.toDoList().last.id!) + 1).toString(),
          todoText: todoController.text),
    );
    todoController.clear();

    setState(() {});
  }

  void remove(int index) {
    setState(() {
      deletedItems.add(toDoList[index].todoText!);
      toDoList.removeAt(index);
    });
  }

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(
          Icons.nightlight_round,
          color: Colors.white,
        );
      }
      return const Icon(
        Icons.wb_sunny,
        color: Colors.amber,
      );
    },
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ThemeModel>(
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor:
                value.isDarkMode ? Colors.black : Colors.grey.shade400,
            appBar: AppBar(
              backgroundColor: value.isDarkMode
                  ? const Color(0xFF424242)
                  : Colors.blueAccent,
              automaticallyImplyLeading: false,
              leading: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DemoPage(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.account_circle_outlined,
                  size: 45.0,
                ),
              ),
              title: const Text('ToDo List'),
              actions: [
                const SizedBox(
                  width: 10.0,
                ),
                Switch(
                  thumbColor: MaterialStatePropertyAll(
                    value.isDarkMode ? Colors.black87 : Colors.white,
                  ),
                  thumbIcon: thumbIcon,
                  activeTrackColor: Colors.white,
                  value: value.isDarkMode,
                  onChanged: (bool value) {
                    value = Provider.of<ThemeModel>(context, listen: false)
                        .toggleTheme();
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      icon: const Icon(
                        Icons.delete_outline_outlined,
                        size: 30.0,
                      ),
                    );
                  },
                ),
              ],
            ),
            endDrawer: Drawer(
              backgroundColor:
                  value.isDarkMode ? Colors.black : Colors.grey.shade400,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    color: value.isDarkMode
                        ? const Color(0xFF424242)
                        : Colors.blueAccent,
                    child: const Text(
                      'Deleted Items',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: deletedItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            deletedItems[index],
                            style: TextStyle(
                              color: value.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          trailing: PopupMenuButton(
                            color:
                                value.isDarkMode ? Colors.white : Colors.black,
                            itemBuilder: (context) {
                              return <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'Remove',
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: value.isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Restore',
                                  child: Text(
                                    'Restore',
                                    style: TextStyle(
                                      color: value.isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ];
                            },
                            onSelected: (value) {
                              if (value == "Remove") {
                                setState(() {
                                  deletedItems.removeAt(index);
                                });
                              } else if (value == "Restore") {
                                setState(
                                  () {
                                    toDoList.add(
                                      ToDo(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        todoText: deletedItems[index],
                                      ),
                                    );
                                    deletedItems.removeAt(index);
                                  },
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    'All ToDos',
                    style: TextStyle(
                      color: value.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: toDoList.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(toDoList[index].id!),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            remove(index);
                          },
                          child: Card(
                            elevation: 3.0,
                            margin: const EdgeInsets.only(top: 8.0),
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(),
                              borderRadius: BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                            ),
                            child: MyToDo(todo: toDoList[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  Form(
                    key: todoKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 7.0),
                          width: 250.0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: value.isDarkMode
                                ? const Color(0xFF424242)
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: Offset.zero,
                                blurRadius: 10.0,
                                spreadRadius: 0.0,
                              )
                            ],
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              color: value.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            controller: todoController,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                color: value.isDarkMode
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                              hintText: 'Enter ToDo to the List',
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a task';
                              }
                              return null;
                            },
                          ),
                        ),
                        ElevatedButton(
                          style: const ButtonStyle(
                              padding: MaterialStatePropertyAll(
                                  EdgeInsets.all(13.0)),
                              shape: MaterialStatePropertyAll(CircleBorder())),
                          onPressed: () {
                            if (todoKey.currentState!.validate()) {
                              adding();
                            }
                          },
                          child: const Icon(Icons.send_outlined),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
