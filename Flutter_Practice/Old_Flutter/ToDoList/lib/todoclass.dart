class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });

  static List<ToDo> toDoList() {
    return [
      ToDo(id: '01', todoText: 'Today Check List', isDone: true),
      ToDo(id: '02', todoText: 'Finishing activities'),
      ToDo(id: '03', todoText: 'Check Emails'),
      ToDo(id: '04', todoText: 'Buying Dress', isDone: true),
      ToDo(id: '05', todoText: 'Buying Sweets'),
      ToDo(id: '06', todoText: 'Went to Native', isDone: true),
    ];
  }
}
