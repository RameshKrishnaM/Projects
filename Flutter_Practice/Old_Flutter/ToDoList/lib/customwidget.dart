import 'package:flutter/material.dart';
import 'package:todolist/todoclass.dart';

class MyToDo extends StatefulWidget {
  final ToDo todo;
  const MyToDo({super.key, required this.todo});

  @override
  State<MyToDo> createState() => _MyToDoState();
}

class _MyToDoState extends State<MyToDo> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          ListTile(
            splashColor: Colors.transparent,
            onTap: () {
              setState(() {
                widget.todo.isDone = !widget.todo.isDone;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            leading: widget.todo.isDone
                ? const Icon(
                    Icons.check_box_outlined,
                    color: Colors.purpleAccent,
                  )
                : const Icon(
                    Icons.check_box_outline_blank_outlined,
                    color: Colors.purpleAccent,
                  ),
            title: Text(
              widget.todo.todoText!,
              style: TextStyle(
                  decoration: widget.todo.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
            ),
          ),
        ],
      ),
    );
  }
}
