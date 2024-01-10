import 'package:flutter/material.dart';
import 'package:keka_to_do_list/Todo.dart';
import 'package:keka_to_do_list/sqflite/todo_db.dart';
import 'package:intl/intl.dart';

class CreateNewTask extends StatefulWidget {
  const CreateNewTask({super.key});

  @override
  State<CreateNewTask> createState() => _CreateNewTaskState();
}

class _CreateNewTaskState extends State<CreateNewTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("New Task"),
      ),
      body: const SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Creating a new Task")
          ],
        ),
      ),
    );
  }
}


class ViewTasks extends StatefulWidget {
  final bool due;
  const ViewTasks({super.key, required this.due});

  @override
  State<ViewTasks> createState() => _ViewTasksState();
}

class _ViewTasksState extends State<ViewTasks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.due ? "Due Tasks" : "Tasks"
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.due ? "Viewing due Tasks" : "Viewing all Tasks",
            )
          ],
        ),
      ),
    );
  }
}

class CreateTodoWidget extends StatefulWidget {
  final Todo? todo;
  final ValueChanged<Map> onSubmit;

  const CreateTodoWidget({super.key, this.todo, required this.onSubmit});

  @override
  State<CreateTodoWidget> createState() => _CreateTodoWidgetState();
}

class _CreateTodoWidgetState extends State<CreateTodoWidget> {

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();
  final priorityController = TextEditingController();
  final categoryController = TextEditingController();
  final newCategoryController = TextEditingController();
  final statusController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> cats = [];

  @override
  void initState() {
    super.initState();
    titleController.text = widget.todo?.data['title'] ?? '';
    descriptionController.text = widget.todo?.data['description'] ?? '';
    dueDateController.text = widget.todo?.data['dueDate'].toString() ?? '';
    priorityController.text = widget.todo?.data['priority'].toString() ?? '-1';
    categoryController.text = widget.todo?.data['category'] ?? '-1';
    statusController.text = widget.todo?.data['status'].toString() ?? '-1';
    newCategoryController.text = "";
    getCats();
  }

  void getCats() async {
    List<String> vals = await TodoDB().fetchCategories();
    vals.add("Other");
    setState(() {
      cats = vals;
      //print(cats);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;
    return SingleChildScrollView(
      child: AlertDialog(
        clipBehavior: Clip.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(0, 10, 25, 10),
        title: Center(
          child: Text(
            isEditing? "Edit Todo" : "Add Todo",
            style: const TextStyle(
              fontWeight: FontWeight.bold
            ),
          )
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  controller: titleController,
                  
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border : OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  ),
                  validator: (value) => value != null && value.isEmpty ? "Title is required" : null,
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border : OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  ),
                  validator: (value) => value != null && value.isEmpty ? "Description is required" : null,
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  showCursor: true,
                  readOnly: true,
                  controller: dueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border : OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context, 
                      initialDate: isEditing ? widget.todo?.data['dueDate'] : DateTime.now(), 
                      firstDate: DateTime.now(), 
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context, 
                      initialTime: isEditing ? TimeOfDay.fromDateTime(widget.todo?.data['dueDate'] ?? DateTime.now()) : TimeOfDay.now(), 
                    );
                    if(pickedDate != null && pickedTime != null){
                      DateTime selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      dueDateController.text = selectedDateTime.toString();
                    }
                  },
                  validator: (value) => value != null && value.isEmpty ? "Due Date is required" : DateTime.parse(value ?? DateTime.now().toString()).compareTo(DateTime.now()) < 0 ? "Due Date Time Cannot be in the Past" : null,
                ),
                const SizedBox(height: 10,),
                DropdownButtonFormField(
                  value: isEditing ? priorityController.text : null, 
                  items: [
                    DropdownMenuItem(
                      value: "0",
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.05,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.yellow,
                            ),
                          ),
                          const SizedBox(width: 10,),
                          const Text("Low"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "1",
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.05,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10,),
                          const Text("Medium"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "2",
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.05,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 10,),
                          const Text("High"),
                        ],
                      ),
                    ),
                  ], 
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border : OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  ),
                  onChanged: (value) {
                    priorityController.text = value.toString();
                  },
                  validator: (value) => value == null ? "Priority is required" : null,
                ),
                const SizedBox(height: 10,),
                DropdownButtonFormField(
                  value: isEditing ? categoryController.text : null, 
                  items: cats.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  },).toList(),
                  onChanged: (value) {
                    if(value.toString() != categoryController.text) {
                      setState(() {
                        cats = cats;
                      });
                    }
                    categoryController.text = value.toString();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border : OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  ),
                  validator: (value) => value == null ? "Category is required" : null,
                ),
                categoryController.text == 'Other' ?
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: TextFormField(
                      controller: newCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Enter New Category',
                        border : OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                      ),
                      validator: (value) => value != null && value.isEmpty ? "New Category is required" : value == "All" ? "Category cannot by named 'All'" : null,
                    ),
                  ) : const SizedBox(),
            
                isEditing ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: DropdownButtonFormField(
                    value: isEditing ? statusController.text : null,
                    items: const [
                      DropdownMenuItem(
                        value: "0",
                        child: Text("New"),
                      ),
                      DropdownMenuItem(
                        value: "1",
                        child: Text("In Progress"),
                      ),
                      DropdownMenuItem(
                        value: "2",
                        child: Text("Completed"),
                      ),
                    ], 
                    onChanged: (value) {
                      statusController.text = value.toString();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border : OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )
                    ),
                    validator: (value) => value != null && value.isEmpty ? "Status is required" : null,
                  ),
                ) : const SizedBox(),
              ],
            )
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if(formKey.currentState!.validate()){
                isEditing ?  widget.onSubmit({'id' : widget.todo?.data['id'], 'newData' : {
                  'title' : titleController.text, 
                  'description' : descriptionController.text, 
                  'dueDate' : dueDateController.text, 
                  'deletedDate' : statusController.text == "2" ? DateTime.now().toString() : "Pending...",
                  'priority': priorityController.text, 
                  'category': categoryController.text == "Other" ? newCategoryController.text : categoryController.text, 
                  'status' : statusController.text
                }}) : 
                widget.onSubmit({'title' : titleController.text, 'description' : descriptionController.text, 'dueDate' : dueDateController.text, 'priority': priorityController.text, 'category': categoryController.text == "Other" ? newCategoryController.text : categoryController.text,  });
              }
            }, 
            child: Text(isEditing ? "Save" : "Add task"),
          ),
        ],
      ),
    );
  }
}

class ViewTodo extends StatefulWidget {
  final Todo? todo;
  final dynamic todoDB;
  final ValueChanged<Map> onSubmit;

  const ViewTodo({super.key, required this.todo, required this.todoDB, required this.onSubmit});

  @override
  State<ViewTodo> createState() => _ViewTodoState();
}

class _ViewTodoState extends State<ViewTodo> {

  bool check = true;

  @override
  Widget build(BuildContext context) {
    // final isEditing = widget.todo != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(0, 10, 25, 10),
          title: Center(
            child: Text(
              "Title - ${widget.todo?.data['title']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
              maxLines: 2,
              overflow: TextOverflow.fade,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Description -",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 0, 30),
                  child: Text(
                    widget.todo?.data['description'],
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Created Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Due Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Completed Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Priority",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Category",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('yyyy-MM-dd').format(widget.todo?.data['createdDate']),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          DateFormat('yyyy-MM-dd').format(widget.todo?.data['dueDate']),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          widget.todo?.data['deletedDate'] == "Pending..." ? "Pending..." : DateFormat('yyyy-MM-dd').format(widget.todo?.data['deletedDate']),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          widget.todo?.data['priority'] == 0 ? "Low" : widget.todo?.data['priority'] == 1 ? "Medium" : "High"
                        ),
                        const SizedBox(height: 10,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.3,
                          child: Text(
                            widget.todo?.data['category'],
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          widget.todo?.data['status'] == 0 ? "New" : widget.todo?.data['status'] == 1 ? "In Progress" : "Completed"
                        )
                      ],
                    ),
                  ],
                )                
                
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text(
                "Close",
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.todo?.data["status"] == 0 ? widget.todo?.data['status'] = 1 : widget.todo?.data["status"] == 1 ? widget.todo?.data['status'] = 2 : widget.todo?.data['status'] = 1;
                Map<String, Object> convertedMap = {};
                widget.todo?.data.forEach((key, value) {
                  convertedMap[key.toString()] = value.toString();
                });
                if(convertedMap['status'] == "2"){
                  convertedMap["deletedDate"] = DateTime.now().toString();
                  widget.todo?.data["deletedDate"] = DateTime.now();
                } else {
                  convertedMap["deletedDate"] = "Pending...";
                  widget.todo?.data["deletedDate"] = "Pending...";
                }
                //print(widget.todo?.data["deletedDate"]);
                widget.onSubmit({
                  'id': widget.todo?.data['id'], 
                  'newData': convertedMap
                });
                setState(() {
                  check = !check;
                });
              }, 
              child: Text(
                (widget.todo?.data["status"] == 2 || widget.todo?.data["status"] == 0) ? "Mark as In Progress" : "Mark as Completed",
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}