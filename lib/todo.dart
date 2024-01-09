class Todo{

  var data = {};
  Todo({
    required this.data,
  });

  editData(String key, String value) {
    data[key] = value;
  }

  factory Todo.fromSqfliteDatabase(Map<String, dynamic> map) => Todo(
    data : {
      'id' : map['id']?.toInt() ?? 0,
      'title' : map['title'] ?? "",
      "description" : map['description'] ?? "",
      "dueDate" : DateTime.parse(map['dueDate'] ?? ""),
      "createdDate" : DateTime.parse(map['createdDate'] ?? ""),
      "deletedDate" : map['deletedDate'] != "Pending..." ? DateTime.parse(map['deletedDate']) : "Pending...",
      "priority": map['priority']?.toInt() ?? 0,
      "category": map['category'] ?? "",
      "status" : map['status']?.toInt() ?? 0
    }
  );
}