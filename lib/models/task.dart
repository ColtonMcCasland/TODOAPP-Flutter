class Task {

  int id; // id for task
  String title; // title for task
  String description; // description for task
  String dueDate; // due date for notification of task
  bool isDone; // indication if task is completed


  //initilizing of task item
  Task({
    this.id,
    this.title,
    this.description,
    this.dueDate,
    this.isDone = false,
  });

  // draw from Map
  factory Task.fromMap(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        dueDate: json["dueDate"],
        isDone: json["isDone"] == 1,
      );

  // write to Map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": id,
      "title": title,
      "description": description,
      "dueDate": dueDate,
      "isDone": isDone ? 1 : 0
    };

    if (id != null) map["id"] = id;

    return map;
  }
}
